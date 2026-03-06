/*{
    "CREDIT": "ossia score",
    "ISFVSN": "2",
    "DESCRIPTION": "Slit Scanner: samples a thin slice from the current frame and scrolls it across a persistent buffer, building an image over time. Horizontal mode: samples a vertical line and scrolls left/right. Vertical mode: samples a horizontal line and scrolls up/down. ",
    "CATEGORIES": [ "Stylize" ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image" },
        { "NAME": "scan_position", "LABEL": "Scan Position",  "TYPE": "float", "DEFAULT": 0.5,   "MIN": 0.0,  "MAX": 1.0 },
        { "NAME": "scroll_speed",  "LABEL": "Scroll Speed",   "TYPE": "float", "DEFAULT": 0.005, "MIN": 0.0,  "MAX": 0.05 },
        { "NAME": "slit_width",    "LABEL": "Slit Width",     "TYPE": "float", "DEFAULT": 0.01,  "MIN": 0.001,"MAX": 0.1 },
        {
            "NAME": "direction",
            "LABEL": "Direction",
            "TYPE": "long",
            "DEFAULT": 0,
            "VALUES": [ 0, 1 ],
            "LABELS": [ "Horizontal scroll", "Vertical scroll" ]
        },
        { "NAME": "fade", "LABEL": "Trail Fade", "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.9, "MAX": 1.0 }
    ],
    "PASSES": [
        { "TARGET": "slitBuffer", "PERSISTENT": true, "FLOAT": true }
    ]
}*/

void main() {
    vec2 uv = isf_FragNormCoord;

    if (direction == 0) {
        // Horizontal scroll: sample vertical slit, push right
        vec2 shiftedUV = vec2(uv.x - scroll_speed, uv.y);
        vec4 old = IMG_NORM_PIXEL(slitBuffer, shiftedUV);
        old.rgb *= fade;

        float dist = abs(uv.x - scroll_speed * 0.5);
        float slitMask = smoothstep(slit_width, 0.0, dist);

        vec4 fresh = IMG_NORM_PIXEL(inputImage, vec2(scan_position, uv.y));
        gl_FragColor = mix(old, fresh, slitMask);
    }
    else {
        // Vertical scroll: sample horizontal slit, push up
        vec2 shiftedUV = vec2(uv.x, uv.y - scroll_speed);
        vec4 old = IMG_NORM_PIXEL(slitBuffer, shiftedUV);
        old.rgb *= fade;

        float dist = abs(uv.y - scroll_speed * 0.5);
        float slitMask = smoothstep(slit_width, 0.0, dist);

        vec4 fresh = IMG_NORM_PIXEL(inputImage, vec2(uv.x, scan_position));
        gl_FragColor = mix(old, fresh, slitMask);
    }
}
