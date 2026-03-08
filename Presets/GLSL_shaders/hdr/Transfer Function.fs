/*{
    "CREDIT": "ossia score HDR pipeline",
    "ISFVSN": "2",
    "DESCRIPTION": "Transfer function conversion. Apply EOTF to linearize encoded signals, or OETF to encode linear light for display. Use at the start or end of an effects chain.",
    "CATEGORIES": [
        "Color"
    ],
    "INPUTS": [
        {
            "NAME": "inputImage",
            "TYPE": "image"
        },
        {
            "NAME": "direction",
            "LABEL": "Direction",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES":  [ 0, 1 ],
            "LABELS":  [ "EOTF (decode to linear)", "OETF (linear to encode)" ]
        },
        {
            "NAME": "transfer",
            "LABEL": "Transfer Function",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES":  [ 0, 1, 2, 3, 4, 5 ],
            "LABELS":  [ "sRGB", "Gamma 2.2", "Gamma 2.4 (BT.1886)", "PQ (ST 2084)", "HLG (BT.2100)", "Linear (no-op)" ]
        },
        {
            "NAME": "pq_scale_nits",
            "LABEL": "PQ Nits Scale",
            "TYPE": "float",
            "DEFAULT": 10000.0,
            "MIN": 1.0,
            "MAX": 10000.0
        }
    ]
}*/

// --- sRGB ---
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

// --- Gamma ---
vec3 gamma_eotf(vec3 v, float g) { return pow(max(v, 0.0), vec3(g)); }
vec3 gamma_oetf(vec3 v, float g) { return pow(max(v, 0.0), vec3(1.0 / g)); }

// --- PQ ---
const float PQ_m1 = 0.1593017578125;
const float PQ_m2 = 78.84375;
const float PQ_c1 = 0.8359375;
const float PQ_c2 = 18.8515625;
const float PQ_c3 = 18.6875;

vec3 pq_eotf(vec3 N) {
    vec3 Np = pow(max(N, 0.0), vec3(1.0 / PQ_m2));
    vec3 L  = pow(max(Np - PQ_c1, 0.0) / (PQ_c2 - PQ_c3 * Np), vec3(1.0 / PQ_m1));
    return L * 10000.0;
}
vec3 pq_oetf(vec3 L) {
    vec3 Lp = pow(max(L / 10000.0, 0.0), vec3(PQ_m1));
    return pow((PQ_c1 + PQ_c2 * Lp) / (1.0 + PQ_c3 * Lp), vec3(PQ_m2));
}

// --- HLG ---
const float HLG_a = 0.17883277;
const float HLG_b = 0.28466892;
const float HLG_c = 0.55991073;

vec3 hlg_eotf(vec3 v) {
    vec3 lo = v * v / 3.0;
    vec3 hi = (exp((v - HLG_c) / HLG_a) + HLG_b) / 12.0;
    return mix(lo, hi, step(vec3(0.5), v));
}
vec3 hlg_oetf(vec3 v) {
    vec3 lo = sqrt(3.0 * max(v, 0.0));
    vec3 hi = HLG_a * log(max(12.0 * v - HLG_b, 1e-10)) + HLG_c;
    return mix(lo, hi, step(vec3(1.0 / 12.0), v));
}

void main() {
    vec3 c = IMG_THIS_PIXEL(inputImage).rgb;

    if (direction == 0) {
        // EOTF: decode to linear
        if (transfer == 0)      c = srgb_eotf(c);
        else if (transfer == 1) c = gamma_eotf(c, 2.2);
        else if (transfer == 2) c = gamma_eotf(c, 2.4);
        else if (transfer == 3) { c = pq_eotf(c); c /= pq_scale_nits; }
        else if (transfer == 4) c = hlg_eotf(c);
        // transfer == 5: linear, no-op
    } else {
        // OETF: linear to encode
        if (transfer == 0)      c = srgb_oetf(c);
        else if (transfer == 1) c = gamma_oetf(c, 2.2);
        else if (transfer == 2) c = gamma_oetf(c, 2.4);
        else if (transfer == 3) c = pq_oetf(c * pq_scale_nits);
        else if (transfer == 4) c = hlg_oetf(c);
        // transfer == 5: linear, no-op
    }

    gl_FragColor = vec4(c, IMG_THIS_PIXEL(inputImage).a);
}
