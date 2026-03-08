/*{
    "CREDIT": "ossia score HDR pipeline",
    "ISFVSN": "2",
    "DESCRIPTION": "Complete HDR/SDR color pipeline with modular stages. Each stage can be independently enabled. Designed for linear-workflow compositing where video frames arrive as linear light from the decoder.",
    "CATEGORIES": [
        "Color"
    ],
    "INPUTS": [
        {
            "NAME": "inputImage",
            "TYPE": "image"
        },

        {
            "NAME": "input_eotf",
            "LABEL": "Input EOTF (Linearize)",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES":  [ 0, 1, 2, 3, 4, 5 ],
            "LABELS":  [ "None (already linear)", "sRGB", "Gamma 2.2", "Gamma 2.4 (BT.1886)", "PQ (ST 2084)", "HLG (BT.2100)" ]
        },
        {
            "NAME": "input_gamut",
            "LABEL": "Input Gamut Conversion",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES":  [ 0, 1, 2 ],
            "LABELS":  [ "None", "BT.2020 to BT.709", "BT.709 to BT.2020" ]
        },
        {
            "NAME": "exposure_enable",
            "LABEL": "Enable Exposure",
            "TYPE": "bool",
            "DEFAULT": false
        },
        {
            "NAME": "exposure_ev",
            "LABEL": "Exposure (EV)",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -6.0,
            "MAX": 6.0
        },
        {
            "NAME": "hlg_system_gamma_enable",
            "LABEL": "Apply HLG OOTF",
            "TYPE": "bool",
            "DEFAULT": false
        },
        {
            "NAME": "hlg_display_peak",
            "LABEL": "HLG Display Peak (nits)",
            "TYPE": "float",
            "DEFAULT": 1000.0,
            "MIN": 100.0,
            "MAX": 4000.0
        },
        {
            "NAME": "normalize_enable",
            "LABEL": "Enable HDR Normalize",
            "TYPE": "bool",
            "DEFAULT": false
        },
        {
            "NAME": "content_peak_nits",
            "LABEL": "Content Peak (nits)",
            "TYPE": "float",
            "DEFAULT": 1000.0,
            "MIN": 100.0,
            "MAX": 10000.0
        },
        {
            "NAME": "sdr_peak_nits",
            "LABEL": "SDR Reference (nits)",
            "TYPE": "float",
            "DEFAULT": 203.0,
            "MIN": 80.0,
            "MAX": 400.0
        },
        {
            "NAME": "tonemap",
            "LABEL": "Tone Mapping",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES":  [ 0, 1, 2, 3, 4, 5, 6, 7, 8 ],
            "LABELS":  [
                "None (passthrough)",
                "BT.2446 Method A",
                "Reinhard (luminance)",
                "Reinhard Extended",
                "Hable (Uncharted 2)",
                "ACES (Hill fit)",
                "AgX (minimal)",
                "Khronos PBR Neutral",
                "Clamp"
            ]
        },
        {
            "NAME": "output_gamut",
            "LABEL": "Output Gamut Conversion",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES":  [ 0, 1, 2 ],
            "LABELS":  [ "None", "BT.2020 to BT.709", "BT.709 to BT.2020" ]
        },
        {
            "NAME": "output_oetf",
            "LABEL": "Output OETF (Encode)",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES":  [ 0, 1, 2, 3, 4, 5 ],
            "LABELS":  [ "None (stay linear)", "sRGB", "Gamma 2.2", "Gamma 2.4 (BT.1886)", "PQ (ST 2084)", "HLG (BT.2100)" ]
        },
        {
            "NAME": "output_clamp",
            "LABEL": "Clamp Output 0-1",
            "TYPE": "bool",
            "DEFAULT": true
        }
    ]
}*/

// ============================================================
//  EOTF / OETF Transfer Functions
//
//  EOTF: electro-optical, converts encoded signal to linear light
//  OETF: optical-electro, converts linear light to encoded signal
// ============================================================

// --- sRGB (IEC 61966-2-1) ---

vec3 srgb_eotf(vec3 v) {
    vec3 lo = v / 12.92;
    vec3 hi = pow((v + 0.055) / 1.055, vec3(2.4));
    return mix(lo, hi, step(vec3(0.04045), v));
}

vec3 srgb_oetf(vec3 v) {
    vec3 lo = v * 12.92;
    vec3 hi = 1.055 * pow(max(v, 0.0), vec3(1.0 / 2.4)) - 0.055;
    return mix(lo, hi, step(vec3(0.0031308), v));
}

// --- Pure power gamma ---

vec3 gamma_eotf(vec3 v, float g) { return pow(max(v, 0.0), vec3(g)); }
vec3 gamma_oetf(vec3 v, float g) { return pow(max(v, 0.0), vec3(1.0 / g)); }

// --- PQ / ST 2084 (1.0 = 10000 nits) ---

const float PQ_m1 = 0.1593017578125;      // 2610/16384
const float PQ_m2 = 78.84375;             // 2523/4096 * 128
const float PQ_c1 = 0.8359375;            // 3424/4096
const float PQ_c2 = 18.8515625;           // 2413/4096 * 32
const float PQ_c3 = 18.6875;              // 2392/4096 * 32

vec3 pq_eotf(vec3 N) {
    vec3 Np = pow(max(N, 0.0), vec3(1.0 / PQ_m2));
    vec3 L  = pow(max(Np - PQ_c1, 0.0) / (PQ_c2 - PQ_c3 * Np), vec3(1.0 / PQ_m1));
    return L * 10000.0;  // output in nits
}

vec3 pq_oetf(vec3 L) {
    vec3 Lp  = pow(max(L / 10000.0, 0.0), vec3(PQ_m1));
    return pow((PQ_c1 + PQ_c2 * Lp) / (1.0 + PQ_c3 * Lp), vec3(PQ_m2));
}

// --- HLG / ARIB STD-B67 ---

const float HLG_a = 0.17883277;
const float HLG_b = 0.28466892;  // 1 - 4a
const float HLG_c = 0.55991073;  // 0.5 - a*ln(4a)

vec3 hlg_eotf(vec3 v) {
    // HLG inverse OETF: signal to scene-linear (relative, 1.0 = reference white)
    vec3 lo = v * v / 3.0;
    vec3 hi = (exp((v - HLG_c) / HLG_a) + HLG_b) / 12.0;
    return mix(lo, hi, step(vec3(0.5), v));
}

vec3 hlg_oetf(vec3 v) {
    // HLG OETF: scene-linear to signal
    vec3 lo = sqrt(3.0 * v);
    vec3 hi = HLG_a * log(12.0 * v - HLG_b) + HLG_c;
    return mix(lo, hi, step(vec3(1.0 / 12.0), v));
}

// --- HLG OOTF (scene to display, applies system gamma) ---

const vec3 hlg_luma = vec3(0.2627, 0.6780, 0.0593);

vec3 hlg_ootf(vec3 scene, float Lw) {
    // BT.2100 system gamma
    float gamma = 1.2 + 0.42 * log(Lw / 1000.0) / log(10.0);
    float Ys = dot(hlg_luma, scene);
    return Lw * pow(max(Ys, 0.0), gamma - 1.0) * scene;
}

// ============================================================
//  Gamut Conversion Matrices
//  All in GLSL column-major order.
//  Computed from CIE 1931 primaries via XYZ, D65 white.
// ============================================================

const mat3 mat_bt2020_to_bt709 = mat3(
     1.6605, -0.1246, -0.0182,
    -0.5876,  1.1329, -0.1006,
    -0.0728, -0.0083,  1.1187
);

const mat3 mat_bt709_to_bt2020 = mat3(
    0.6274, 0.0691, 0.0164,
    0.3293, 0.9195, 0.0880,
    0.0433, 0.0114, 0.8956
);

vec3 gamut_convert(vec3 c, int mode) {
    if (mode == 1) return mat_bt2020_to_bt709 * c;
    if (mode == 2) return mat_bt709_to_bt2020 * c;
    return c;
}

// ============================================================
//  Tone Mapping Operators
//
//  All expect: linear light, 1.0 = SDR diffuse white.
//  Values > 1.0 are HDR highlights to be compressed.
//  Output: [0, 1] linear light.
//
//  Luminance-based operators (BT.2446, Reinhard, Reinhard Extended)
//  should be applied BEFORE gamut conversion.
//  Per-channel operators (Hable, ACES, AgX, PBR Neutral)
//  should be applied AFTER converting to BT.709.
//  The ISF pipeline leaves this ordering to the user via the
//  input_gamut / output_gamut controls.
// ============================================================

// --- BT.2446 Method A (luminance-based, BT.2020-aware) ---
//     Faithful implementation per ITU-R BT.2446-1 (2021).
//     Uses BT.2020 luma coefficients. Expects BT.2020 primaries.

vec3 tonemap_bt2446a(vec3 color, float srcPeak, float dstPeak) {
    float p_hdr = 1.0 + 32.0 * pow(srcPeak / 10000.0, 1.0 / 2.4);
    float p_sdr = 1.0 + 32.0 * pow(dstPeak / 10000.0, 1.0 / 2.4);
    float gcr = hlg_luma.r / hlg_luma.g;
    float gcb = hlg_luma.b / hlg_luma.g;

    // Perceptual prep: raise to 1/2.4 power
    vec3 xp = pow(max(color * (dstPeak / srcPeak), 0.0), vec3(1.0 / 2.4));
    float y_hdr = dot(hlg_luma, xp);
    if (y_hdr <= 0.0) return vec3(0.0);

    // Perceptual-domain luminance
    float yp = log(1.0 + (p_hdr - 1.0) * y_hdr) / log(p_hdr);

    // Three-segment knee
    float yc;
    if (yp <= 0.7399)
        yc = 1.077 * yp;
    else if (yp <= 0.9909)
        yc = (-1.1510 * yp + 2.7811) * yp - 0.6302;
    else
        yc = 0.5 * yp + 0.5;

    // Back to gamma domain
    float y_sdr = (pow(p_sdr, yc) - 1.0) / (p_sdr - 1.0);

    // Chroma correction
    float scale = y_sdr / (1.1 * y_hdr);
    float cb_tmo = scale * (xp.b - y_hdr);
    float cr_tmo = scale * (xp.r - y_hdr);
    float y_tmo  = y_sdr - max(0.1 * cr_tmo, 0.0);
    float cg_tmo = -(gcr * cr_tmo + gcb * cb_tmo);

    // Back to linear
    vec3 rgb_gamma = y_tmo + vec3(cr_tmo, cg_tmo, cb_tmo);
    return pow(max(rgb_gamma, 0.0), vec3(2.4));
}

// --- Reinhard (simple luminance-based) ---

vec3 tonemap_reinhard(vec3 c) {
    float L = dot(hlg_luma, c);
    if (L <= 0.0) return vec3(0.0);
    float Lout = L / (1.0 + L);
    return c * (Lout / L);
}

// --- Reinhard Extended (luminance-based with white point) ---

vec3 tonemap_reinhard_ext(vec3 c, float wp) {
    float L = dot(hlg_luma, c);
    if (L <= 0.0) return vec3(0.0);
    float Lout = (L * (1.0 + L / (wp * wp))) / (1.0 + L);
    return c * (Lout / L);
}

// --- Hable / Uncharted 2 (per-channel) ---

vec3 hable_curve(vec3 x) {
    const float A = 0.15, B = 0.50, C = 0.10, D = 0.20, E = 0.02, F = 0.30;
    return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
}

vec3 tonemap_hable(vec3 c, float wp) {
    vec3 mapped = hable_curve(c * 2.0);  // exposure bias
    vec3 white  = 1.0 / hable_curve(vec3(wp));
    return mapped * white;
}

// --- ACES (Stephen Hill RRT+ODT fit, expects BT.709 input) ---

vec3 tonemap_aces(vec3 c) {
    const mat3 ACESInput = mat3(
        0.59719, 0.07600, 0.02840,
        0.35458, 0.90834, 0.13383,
        0.04823, 0.01566, 0.83777
    );
    const mat3 ACESOutput = mat3(
         1.60475, -0.10208, -0.00327,
        -0.53108,  1.10813, -0.07276,
        -0.07367, -0.00605,  1.07602
    );
    vec3 v = ACESInput * c;
    vec3 a = v * (v + 0.0245786) - 0.000090537;
    vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
    return ACESOutput * (a / b);
}

// --- AgX (minimal algebraic, expects BT.709 input) ---

vec3 agx_default_contrast(vec3 x) {
    vec3 x2 = x * x;
    vec3 x4 = x2 * x2;
    return + 15.5     * x4 * x2
           - 40.14    * x4 * x
           + 31.96    * x4
           - 6.868    * x2 * x
           + 0.4298   * x2
           + 0.1191   * x
           - 0.00232;
}

vec3 tonemap_agx(vec3 c) {
    const mat3 agxFwd = mat3(
        0.842479062253094,  0.0423282422610123, 0.0423756549057051,
        0.0784335999999992, 0.878468636469772,  0.0784336,
        0.0792237451477643, 0.0791661274605434, 0.879142973793104
    );
    const mat3 agxInv = mat3(
         1.19687900512017,  -0.0528968517574562, -0.0529716355144438,
        -0.0980208811401368,  1.15190312990417,  -0.0980434501171241,
        -0.0990297440797205, -0.0989611768448433,  1.15107367264116
    );
    const float minEV = -12.47393;
    const float maxEV =   4.026069;

    vec3 v = agxFwd * c;
    v = max(v, 1e-10);
    v = clamp(log2(v), minEV, maxEV);
    v = (v - minEV) / (maxEV - minEV);
    v = agx_default_contrast(v);
    return agxInv * v;
}

// --- Khronos PBR Neutral (gamut-agnostic) ---

vec3 tonemap_pbr_neutral(vec3 c) {
    const float startCompression = 0.8 - 0.04;
    const float desaturation = 0.15;

    float x = min(c.r, min(c.g, c.b));
    float offset = (x < 0.08) ? x - 6.25 * x * x : 0.04;
    c -= offset;

    float peak = max(c.r, max(c.g, c.b));
    if (peak < startCompression) return c;

    float d = 1.0 - startCompression;
    float newPeak = 1.0 - d * d / (peak + d - startCompression);
    c *= newPeak / peak;

    float g = 1.0 - 1.0 / (desaturation * (peak - newPeak) + 1.0);
    return mix(c, vec3(newPeak), g);
}


// ============================================================
//  Main Pipeline
//
//  The stages execute in order:
//    1. Input EOTF (linearize)
//    2. HLG OOTF (if enabled, for HLG scenetodisplay)
//    3. Input gamut conversion
//    4. Exposure adjustment
//    5. HDR normalization (scale to 1.0 = SDR white)
//    6. Tone mapping
//    7. Output gamut conversion
//    8. Output OETF (encode for display)
//    9. Clamp
// ============================================================

void main() {
    vec3 c = IMG_THIS_PIXEL(inputImage).rgb;

    // ── Stage 1: Input EOTF (signal to linear light) ──
    if (input_eotf == 1)      c = srgb_eotf(c);
    else if (input_eotf == 2) c = gamma_eotf(c, 2.2);
    else if (input_eotf == 3) c = gamma_eotf(c, 2.4);
    else if (input_eotf == 4) c = pq_eotf(c);         // output in nits
    else if (input_eotf == 5) c = hlg_eotf(c);         // output scene-relative

    // ── Stage 2: HLG OOTF (scene-linear to display-linear) ──
    if (hlg_system_gamma_enable) {
        c = hlg_ootf(c, hlg_display_peak);
    }

    // ── Stage 3: Input gamut conversion ──
    c = gamut_convert(c, input_gamut);

    // ── Stage 4: Exposure ──
    if (exposure_enable) {
        c *= pow(2.0, exposure_ev);
    }

    // ── Stage 5: HDR normalization ──
    //    Scales absolute nits (from PQ) or arbitrary linear values
    //    so that 1.0 = SDR reference white.
    //    For PQ input: divide by sdr_peak_nits (e.g., 203).
    //    For other inputs: scale by content_peak / sdr_peak.
    if (normalize_enable) {
        if (input_eotf == 4) {
            // PQ EOTF outputs nits directly
            c /= sdr_peak_nits;
        } else {
            // Content-peak normalization (1.0 = content peak to 1.0 = SDR white)
            c *= content_peak_nits / sdr_peak_nits;
        }
    }

    // ── Stage 6: Tone mapping ──
    if (tonemap == 1) {
        c = tonemap_bt2446a(c, content_peak_nits, sdr_peak_nits);
    }
    else if (tonemap == 2) {
        c = tonemap_reinhard(c);
    }
    else if (tonemap == 3) {
        float wp = content_peak_nits / sdr_peak_nits;
        c = tonemap_reinhard_ext(c, wp);
    }
    else if (tonemap == 4) {
        float wp = content_peak_nits / sdr_peak_nits;
        c = tonemap_hable(c, wp);
    }
    else if (tonemap == 5) {
        c = clamp(tonemap_aces(c), 0.0, 1.0);
    }
    else if (tonemap == 6) {
        c = clamp(tonemap_agx(c), 0.0, 1.0);
    }
    else if (tonemap == 7) {
        c = clamp(tonemap_pbr_neutral(c), 0.0, 1.0);
    }
    else if (tonemap == 8) {
        c = clamp(c, 0.0, 1.0);
    }

    // ── Stage 7: Output gamut conversion ──
    c = gamut_convert(c, output_gamut);

    // ── Stage 8: Output OETF (linear to encoded signal) ──
    if (output_oetf == 1)      c = srgb_oetf(c);
    else if (output_oetf == 2) c = gamma_oetf(c, 2.2);
    else if (output_oetf == 3) c = gamma_oetf(c, 2.4);
    else if (output_oetf == 4) c = pq_oetf(c * sdr_peak_nits); // scale back to nits for PQ
    else if (output_oetf == 5) c = hlg_oetf(c);

    // ── Stage 9: Clamp ──
    if (output_clamp) c = clamp(c, 0.0, 1.0);

    gl_FragColor = vec4(c, IMG_THIS_PIXEL(inputImage).a);
}
