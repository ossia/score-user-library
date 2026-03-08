/*{
    "CREDIT": "ossia score HDR pipeline",
    "ISFVSN": "2",
    "DESCRIPTION": "Tone mapping for HDRtoSDR conversion. Expects linear-light input where 1.0 = SDR reference white and values > 1.0 are HDR highlights. Luminance-based operators (BT.2446, Reinhard) preserve hue; per-channel operators (ACES, AgX) reshape color.",
    "CATEGORIES": [
        "Color"
    ],
    "INPUTS": [
        {
            "NAME": "inputImage",
            "TYPE": "image"
        },
        {
            "NAME": "tonemap",
            "LABEL": "Algorithm",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES":  [ 0, 1, 2, 3, 4, 5, 6, 7 ],
            "LABELS":  [
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
            "NAME": "exposure_ev",
            "LABEL": "Pre-Exposure (EV)",
            "TYPE": "float",
            "DEFAULT": 0.0,
            "MIN": -4.0,
            "MAX": 4.0
        },
        {
            "NAME": "content_peak",
            "LABEL": "Content Peak / SDR White",
            "TYPE": "float",
            "DEFAULT": 4.926,
            "MIN": 1.0,
            "MAX": 50.0
        },
        {
            "NAME": "saturation",
            "LABEL": "Post-Tonemap Saturation",
            "TYPE": "float",
            "DEFAULT": 1.0,
            "MIN": 0.0,
            "MAX": 2.0
        }
    ]
}*/

const vec3 luma_2020 = vec3(0.2627, 0.6780, 0.0593);
const vec3 luma_709  = vec3(0.2126, 0.7152, 0.0722);

// ── BT.2446 Method A ──
vec3 tm_bt2446a(vec3 color, float peakRatio) {
    float srcPeak = peakRatio * 203.0;  // content peak in nits
    float dstPeak = 203.0;             // SDR reference white

    float p_hdr = 1.0 + 32.0 * pow(srcPeak / 10000.0, 1.0 / 2.4);
    float p_sdr = 1.0 + 32.0 * pow(dstPeak / 10000.0, 1.0 / 2.4);
    float gcr = luma_2020.r / luma_2020.g;
    float gcb = luma_2020.b / luma_2020.g;

    vec3 xp = pow(max(color / peakRatio, 0.0), vec3(1.0 / 2.4));
    float y_hdr = dot(luma_2020, xp);
    if (y_hdr <= 0.0) return vec3(0.0);

    float yp = log(1.0 + (p_hdr - 1.0) * y_hdr) / log(p_hdr);

    float yc;
    if (yp <= 0.7399)      yc = 1.077 * yp;
    else if (yp <= 0.9909) yc = (-1.1510 * yp + 2.7811) * yp - 0.6302;
    else                    yc = 0.5 * yp + 0.5;

    float y_sdr = (pow(p_sdr, yc) - 1.0) / (p_sdr - 1.0);

    float sc = y_sdr / (1.1 * y_hdr);
    float cb = sc * (xp.b - y_hdr);
    float cr = sc * (xp.r - y_hdr);
    float yt = y_sdr - max(0.1 * cr, 0.0);
    float cg = -(gcr * cr + gcb * cb);

    return pow(max(yt + vec3(cr, cg, cb), 0.0), vec3(2.4));
}

// ── Reinhard ──
vec3 tm_reinhard(vec3 c) {
    float L = dot(luma_709, c);
    if (L <= 0.0) return vec3(0.0);
    return c * (L / (1.0 + L)) / L;
}

// ── Reinhard Extended ──
vec3 tm_reinhard_ext(vec3 c, float wp) {
    float L = dot(luma_709, c);
    if (L <= 0.0) return vec3(0.0);
    float Lout = (L * (1.0 + L / (wp * wp))) / (1.0 + L);
    return c * (Lout / L);
}

// ── Hable ──
vec3 hable_f(vec3 x) {
    const float A = 0.15, B = 0.50, C = 0.10, D = 0.20, E = 0.02, F = 0.30;
    return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
}
vec3 tm_hable(vec3 c, float wp) {
    return hable_f(c * 2.0) * (1.0 / hable_f(vec3(wp)));
}

// ── ACES ──
vec3 tm_aces(vec3 c) {
    const mat3 I = mat3(
        0.59719, 0.07600, 0.02840,
        0.35458, 0.90834, 0.13383,
        0.04823, 0.01566, 0.83777);
    const mat3 O = mat3(
         1.60475, -0.10208, -0.00327,
        -0.53108,  1.10813, -0.07276,
        -0.07367, -0.00605,  1.07602);
    vec3 v = I * c;
    vec3 a = v * (v + 0.0245786) - 0.000090537;
    vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
    return O * (a / b);
}

// ── AgX ──
vec3 agx_contrast(vec3 x) {
    vec3 x2 = x * x; vec3 x4 = x2 * x2;
    return 15.5*x4*x2 - 40.14*x4*x + 31.96*x4 - 6.868*x2*x + 0.4298*x2 + 0.1191*x - 0.00232;
}
vec3 tm_agx(vec3 c) {
    const mat3 F = mat3(
        0.842479062253094,  0.0423282422610123, 0.0423756549057051,
        0.0784335999999992, 0.878468636469772,  0.0784336,
        0.0792237451477643, 0.0791661274605434, 0.879142973793104);
    const mat3 R = mat3(
         1.19687900512017,  -0.0528968517574562, -0.0529716355144438,
        -0.0980208811401368,  1.15190312990417,  -0.0980434501171241,
        -0.0990297440797205, -0.0989611768448433,  1.15107367264116);
    vec3 v = F * c;
    v = max(v, 1e-10);
    v = clamp(log2(v), -12.47393, 4.026069);
    v = (v + 12.47393) / (4.026069 + 12.47393);
    return R * agx_contrast(v);
}

// ── PBR Neutral ──
vec3 tm_pbr(vec3 c) {
    const float sc = 0.76, ds = 0.15;
    float x = min(c.r, min(c.g, c.b));
    float off = (x < 0.08) ? x - 6.25*x*x : 0.04;
    c -= off;
    float pk = max(c.r, max(c.g, c.b));
    if (pk < sc) return c;
    float d = 1.0 - sc;
    float np = 1.0 - d*d / (pk + d - sc);
    c *= np / pk;
    float g = 1.0 - 1.0 / (ds * (pk - np) + 1.0);
    return mix(c, vec3(np), g);
}

void main() {
    vec3 c = IMG_THIS_PIXEL(inputImage).rgb;

    // Pre-exposure
    c *= pow(2.0, exposure_ev);

    // Tone map
    if (tonemap == 0)      c = tm_bt2446a(c, content_peak);
    else if (tonemap == 1) c = tm_reinhard(c);
    else if (tonemap == 2) c = tm_reinhard_ext(c, content_peak);
    else if (tonemap == 3) c = tm_hable(c, content_peak);
    else if (tonemap == 4) c = clamp(tm_aces(c), 0.0, 1.0);
    else if (tonemap == 5) c = clamp(tm_agx(c), 0.0, 1.0);
    else if (tonemap == 6) c = clamp(tm_pbr(c), 0.0, 1.0);
    else if (tonemap == 7) c = clamp(c, 0.0, 1.0);

    // Post-tonemap saturation
    if (saturation != 1.0) {
        float lum = dot(luma_709, c);
        c = mix(vec3(lum), c, saturation);
    }

    gl_FragColor = vec4(c, IMG_THIS_PIXEL(inputImage).a);
}
