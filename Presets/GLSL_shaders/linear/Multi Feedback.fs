/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Feedback with luma key, transform, and hue shift. The input is keyed by brightness, then composited onto a feedback buffer that is continuously panned, zoomed, rotated, and hue-shifted. Produces classic VJ feedback spirals, tunnels, and trails.",
    "CATEGORIES": [ "Stylize" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        { "NAME": "feedback_mix",  "LABEL": "Feedback Amount",  "TYPE": "float", "DEFAULT": 0.85, "MIN": 0.0,    "MAX": 0.99 },
        { "NAME": "luma_thresh",   "LABEL": "Luma Threshold",   "TYPE": "float", "DEFAULT": 0.2,  "MIN": 0.0,    "MAX": 1.0 },
        { "NAME": "luma_soft",     "LABEL": "Luma Softness",    "TYPE": "float", "DEFAULT": 0.1,  "MIN": 0.0,    "MAX": 0.5 },
        { "NAME": "fb_zoom",       "LABEL": "Zoom",             "TYPE": "float", "DEFAULT": 0.98, "MIN": 0.9,    "MAX": 1.1 },
        { "NAME": "fb_rotate",     "LABEL": "Rotate (degrees)", "TYPE": "float", "DEFAULT": 0.0,  "MIN": -10.0,  "MAX": 10.0 },
        { "NAME": "fb_pan_x",      "LABEL": "Pan X",            "TYPE": "float", "DEFAULT": 0.0,  "MIN": -0.05,  "MAX": 0.05 },
        { "NAME": "fb_pan_y",      "LABEL": "Pan Y",            "TYPE": "float", "DEFAULT": 0.0,  "MIN": -0.05,  "MAX": 0.05 },
        { "NAME": "fb_hue_shift",  "LABEL": "Hue Shift",        "TYPE": "float", "DEFAULT": 0.0,  "MIN": 0.0,    "MAX": 1.0 },
        { "NAME": "fb_saturation", "LABEL": "Feedback Sat",     "TYPE": "float", "DEFAULT": 1.0,  "MIN": 0.5,    "MAX": 1.5 }
    ],
    "PASSES": [
        { "TARGET": "feedbackBuffer", "PERSISTENT": true, "FLOAT": true }
    ]
}*/

const vec3 luma_coeff = vec3(0.2126, 0.7152, 0.0722);

vec3 hueShift(vec3 c, float shift) {
    if (shift < 0.001) return c;
    float angle = shift * 6.28318530718;
    float cosA = cos(angle);
    float sinA = sin(angle);
    vec3 k = vec3(0.57735);
    return c * cosA + cross(k, c) * sinA + k * dot(k, c) * (1.0 - cosA);
}

void main() {
    vec2 uv = isf_FragNormCoord;
    vec4 fresh = IMG_NORM_PIXEL(inputImage, uv);

    float L = dot(luma_coeff, fresh.rgb);
    float key = smoothstep(luma_thresh, luma_thresh + luma_soft, L);

    vec2 center = vec2(0.5);
    vec2 fbUV = uv - center;
    fbUV /= fb_zoom;
    float rad = fb_rotate * 3.14159265 / 180.0;
    float co = cos(rad), si = sin(rad);
    fbUV = vec2(fbUV.x * co - fbUV.y * si, fbUV.x * si + fbUV.y * co);
    fbUV += center + vec2(fb_pan_x, fb_pan_y);

    vec4 stale = IMG_NORM_PIXEL(feedbackBuffer, fbUV);
    stale.rgb = hueShift(stale.rgb, fb_hue_shift);
    float sL = dot(luma_coeff, stale.rgb);
    stale.rgb = sL + (stale.rgb - sL) * fb_saturation;
    stale.rgb *= feedback_mix;

    vec3 result = mix(stale.rgb, fresh.rgb, key);
    gl_FragColor = vec4(result, fresh.a);
}
