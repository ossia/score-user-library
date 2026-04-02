/*{
    "DESCRIPTION": "Applies a customizable Domemaster mask defined by a polar angle range, a color, and a feathered edge (softness). Assumes the input is a 210-degree FOV Domemaster projection.",
    "CREDIT": "AI Assistant (Gemini)",
    "CATEGORIES": [
        "TRANSFORM",
        "DOME",
        "MASK"
    ],
    "INPUTS": [
        { "NAME": "inputImage", "TYPE": "image", "LABEL": "Domemaster Input" },
        { "NAME": "keep_1_1_aspect", "LABEL": "Keep 1:1 Input Aspect", "TYPE": "bool", "DEFAULT": true },
        { "NAME": "mask_polar_angle_degrees", "LABEL": "Mask Polar Angle Degrees (0 to 60)", "TYPE": "float", "DEFAULT": 14.0, "MIN": 0.0, "MAX": 60.0 },
        { "NAME": "mask_softness_degrees", "LABEL": "Mask Softness (Feathering Degrees)", "TYPE": "float", "DEFAULT": 1.0, "MIN": 0.0, "MAX": 30.0 },
        { "NAME": "mask_color", "LABEL": "Mask Color (incl. Alpha)", "TYPE": "color", "DEFAULT": [0.0, 0.0, 0.0, 1.0] }
    ]
}*/

// Mathematical constants
#define M_PI 3.14159265359

void main() {
    // 1. Normalize and center the fragment coordinates to [-1, 1]
    vec2 p_centered = (vv_FragNormCoord - 0.5) * 2.0;

    // 2. Correct for aspect ratio to keep math perfectly circular
    float screen_aspect = RENDERSIZE.x / RENDERSIZE.y;
    if (screen_aspect > 1.0) { p_centered.x *= screen_aspect; }
    else { p_centered.y /= screen_aspect; }

    // 3. Sample the input image
    vec4 source_color;
    if (keep_1_1_aspect) {
        // Un-center the corrected coordinates back to [0, 1] UV space
        vec2 sample_uv = (p_centered * 0.5) + 0.5;
        
        // Prevent repeating/smearing outside the 1:1 image bounds
        if (sample_uv.x < 0.0 || sample_uv.x > 1.0 || sample_uv.y < 0.0 || sample_uv.y > 1.0) {
            source_color = vec4(0.0); 
        } else {
            source_color = IMG_NORM_PIXEL(inputImage, sample_uv);
        }
    } else {
        // Default behavior (maps texture to full window bounds)
        source_color = IMG_THIS_PIXEL(inputImage);
    }

    // 4. Calculate the distance from the center (normalized radius)
    float dist_from_center = length(p_centered);

    // --- Uniform Calculations ---
    float half_fov_degrees = 105.0; 
    float mask_start_polar_angle = half_fov_degrees - mask_polar_angle_degrees;
    float fade_start_polar_angle = mask_start_polar_angle - mask_softness_degrees;
    
    float fade_end_radius = mask_start_polar_angle / half_fov_degrees; 
    float fade_start_radius = fade_start_polar_angle / half_fov_degrees; 
    fade_start_radius = max(0.0, fade_start_radius); 
    
    // --- Masking Logic ---
    if (dist_from_center > 1.0) {
        isf_FragColor = mask_color; 
        return;
    }

    float mask_factor = smoothstep(fade_start_radius, fade_end_radius, dist_from_center);
    isf_FragColor = mix(source_color, mask_color, mask_factor);
}