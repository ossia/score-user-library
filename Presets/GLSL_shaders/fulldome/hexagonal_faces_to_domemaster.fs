/*{
    "DESCRIPTION": "Hexagonal Prism Domemaster. 6 side faces (split into top/bottom halves, bottom rotated 180) + 2 pole faces. Preserves transparency.",
    "CREDIT": "Edu Meneses + AI Assistant (Gemini)",
    "CATEGORIES": [
        "GENERATOR",
        "3D",
        "DOME"
    ],
    "INPUTS": [
        { "NAME": "side1_Top", "TYPE": "image", "LABEL": "Side 1 Top (0°)" },
        { "NAME": "side1_Bot", "TYPE": "image", "LABEL": "Side 1 Bot (0° - 180 Rot)" },
        { "NAME": "side2_Top", "TYPE": "image", "LABEL": "Side 2 Top (60°)" },
        { "NAME": "side2_Bot", "TYPE": "image", "LABEL": "Side 2 Bot (60° - 180 Rot)" },
        { "NAME": "side3_Top", "TYPE": "image", "LABEL": "Side 3 Top (120°)" },
        { "NAME": "side3_Bot", "TYPE": "image", "LABEL": "Side 3 Bot (120° - 180 Rot)" },
        { "NAME": "side4_Top", "TYPE": "image", "LABEL": "Side 4 Top (180°)" },
        { "NAME": "side4_Bot", "TYPE": "image", "LABEL": "Side 4 Bot (180° - 180 Rot)" },
        { "NAME": "side5_Top", "TYPE": "image", "LABEL": "Side 5 Top (240°)" },
        { "NAME": "side5_Bot", "TYPE": "image", "LABEL": "Side 5 Bot (240° - 180 Rot)" },
        { "NAME": "side6_Top", "TYPE": "image", "LABEL": "Side 6 Top (300°)" },
        { "NAME": "side6_Bot", "TYPE": "image", "LABEL": "Side 6 Bot (300° - 180 Rot)" },
        { "NAME": "poleTop", "TYPE": "image", "LABEL": "Top Pole (+Y Zenith)" },
        { "NAME": "poleBot", "TYPE": "image", "LABEL": "Bottom Pole (-Y Nadir)" },
        { "NAME": "alpha1", "LABEL": "Alpha (Top Imgs)", "TYPE": "float", "MIN": 0.0, "MAX": 1.0, "DEFAULT": 1.0 },
        { "NAME": "alpha2", "LABEL": "Alpha (Bottom Imgs)", "TYPE": "float", "MIN": 0.0, "MAX": 1.0, "DEFAULT": 1.0 },
        { "NAME": "rotate_x", "LABEL": "Rotate X (0-1, Yaw)", "TYPE": "float", "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "rotate_y", "LABEL": "Rotate Y (0-1, Pitch)", "TYPE": "float", "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "rotate_z", "LABEL": "Rotate Z (0-1, Roll)", "TYPE": "float", "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "domemaster_output_fov_degrees", "LABEL": "Domemaster Output FOV", "TYPE": "float", "DEFAULT": 180.0, "MIN": 1.0, "MAX": 360.0 },
        { "NAME": "flip_input_x", "LABEL": "Flip Inputs Horizontally", "TYPE": "bool", "DEFAULT": false },
        { "NAME": "flip_input_y", "LABEL": "Flip Inputs Vertically (GL/VK)", "TYPE": "bool", "DEFAULT": false }
    ],
    "ISFVSN": "2"
}*/

#define M_PI 3.14159265359
#define TWO_PI 6.28318530718
#define TAN_30 0.57735026919
#define HEX_CORNER_RADIUS 1.15470053839

// Creates a rotation matrix from Euler angles (Yaw, Pitch, Roll).
mat3 makeRotationMatrix(vec3 euler_angles) {
    float cos_yaw   = cos(euler_angles.x); float sin_yaw   = sin(euler_angles.x);
    float cos_pitch = cos(euler_angles.y); float sin_pitch = sin(euler_angles.y);
    float cos_roll  = cos(euler_angles.z); float sin_roll  = sin(euler_angles.z);

    return mat3(
        cos_yaw * cos_roll - sin_yaw * cos_pitch * sin_roll,
        -cos_yaw * sin_roll - sin_yaw * cos_pitch * cos_roll,
        sin_yaw * sin_pitch,
        sin_yaw * cos_roll + cos_yaw * cos_pitch * sin_roll,
        -sin_yaw * sin_roll + cos_yaw * cos_pitch * cos_roll,
        -cos_yaw * sin_pitch,
        sin_pitch * sin_roll,
        sin_pitch * cos_roll,
        cos_pitch
    );
}

// Helper to correct UVs based on the graphics API or mirroring needs
vec2 flipUV(vec2 uv) {
    vec2 flipped = uv;
    if (flip_input_x) flipped.x = 1.0 - flipped.x;
    if (flip_input_y) flipped.y = 1.0 - flipped.y;
    return flipped;
}

void main() {
    // --- Center and aspect ratio correction ---
    vec2 p_centered = (vv_FragNormCoord - 0.5) * 2.0;
    float screen_aspect = RENDERSIZE.x / RENDERSIZE.y;
    if (screen_aspect > 1.0) { p_centered.x *= screen_aspect; }
    else { p_centered.y /= screen_aspect; }

    // --- Circular Domemaster Mask ---
    float dist_from_center = length(p_centered);
    if (dist_from_center > 1.0) {
        isf_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    // --- Projection Calculations ---
    float yaw   = rotate_x * TWO_PI;
    float pitch = rotate_y * M_PI;
    float roll  = rotate_z * TWO_PI;
    mat3 inverse_content_rotation_matrix = transpose(makeRotationMatrix(vec3(yaw, pitch, roll)));
    float fisheye_half_fov_rad = domemaster_output_fov_degrees * (M_PI / 360.0);
    
    float ray_polar_angle = dist_from_center * fisheye_half_fov_rad;
    float ray_azimuth_angle = atan(p_centered.y, p_centered.x);

    vec3 ray_dir_world = vec3(
        sin(ray_polar_angle) * cos(ray_azimuth_angle),
        sin(ray_polar_angle) * sin(ray_azimuth_angle),
        cos(ray_polar_angle)
    );
    vec3 local_ray_dir = inverse_content_rotation_matrix * ray_dir_world;

    // --- Target Face Selection for Hexagonal Prism ---
    vec3 dir = local_ray_dir;
    
    // 1. Find angle around the Y axis
    float theta = atan(dir.z, dir.x);
    if (theta < 0.0) theta += TWO_PI;
    
    // 2. Determine which of the 6 faces we hit (offset by 30 deg so face 0 is centered on X)
    float face_idx = floor((theta + M_PI / 6.0) / (M_PI / 3.0));
    if (face_idx >= 6.0) face_idx -= 6.0;
    
    // 3. Calculate the normal of that face
    float phi = face_idx * (M_PI / 3.0);
    vec3 N = vec3(cos(phi), 0.0, sin(phi));
    
    // 4. Ray-plane intersection distances
    float t_side = 1.0 / dot(N, dir); // Distance to the hex wall
    float t_y = 1.0 / abs(dir.y);     // Distance to the top/bot caps

    vec2 final_uv;
    vec4 sampled_color = vec4(0.0);

    if (t_side < t_y) {
        // --- Hit one of the 6 Side Faces ---
        vec3 P = dir * t_side;
        vec3 T = vec3(-sin(phi), 0.0, cos(phi)); // Tangent vector along the face
        
        float u = dot(P, T); // Ranges from -TAN_30 to +TAN_30
        float v = P.y;       // Ranges from -1.0 to 1.0
        
        // Map to 0.0 -> 1.0 UV space
        final_uv.x = (u / TAN_30 + 1.0) * 0.5;
        final_uv.y = (v + 1.0) * 0.5;
        
        int idx = int(face_idx);
        
        // Split logic: Top half vs Bottom half (180 rotated)
        if (final_uv.y >= 0.5) {
            vec2 top_uv = flipUV(vec2(final_uv.x, (final_uv.y - 0.5) * 2.0));
            
            if (idx == 0)      sampled_color = IMG_NORM_PIXEL(side1_Top, top_uv);
            else if (idx == 1) sampled_color = IMG_NORM_PIXEL(side6_Top, top_uv);
            else if (idx == 2) sampled_color = IMG_NORM_PIXEL(side5_Top, top_uv);
            else if (idx == 3) sampled_color = IMG_NORM_PIXEL(side4_Top, top_uv);
            else if (idx == 4) sampled_color = IMG_NORM_PIXEL(side3_Top, top_uv);
            else               sampled_color = IMG_NORM_PIXEL(side2_Top, top_uv);
            
            sampled_color.rgb *= alpha1; // Fade to black preserving transparency
        } else {
            vec2 bot_uv = flipUV(vec2(1.0 - final_uv.x, 1.0 - (final_uv.y * 2.0)));
            
            if (idx == 0)      sampled_color = IMG_NORM_PIXEL(side1_Bot, bot_uv);
            else if (idx == 1) sampled_color = IMG_NORM_PIXEL(side6_Bot, bot_uv);
            else if (idx == 2) sampled_color = IMG_NORM_PIXEL(side5_Bot, bot_uv);
            else if (idx == 3) sampled_color = IMG_NORM_PIXEL(side4_Bot, bot_uv);
            else if (idx == 4) sampled_color = IMG_NORM_PIXEL(side3_Bot, bot_uv);
            else               sampled_color = IMG_NORM_PIXEL(side2_Bot, bot_uv);
            
            sampled_color.rgb *= alpha2; // Fade to black preserving transparency
        }
        
    } else {
        // --- Hit Top or Bottom Pole ---
        vec3 P = dir * t_y;
        
        // The hex corners extend to 1.1547. Dividing by this value guarantees 
        // the hexagon fits entirely inside the square input, discarding the corners.
        final_uv.x = (P.x / HEX_CORNER_RADIUS + 1.0) * 0.5;
        final_uv.y = (P.z / HEX_CORNER_RADIUS + 1.0) * 0.5;
        final_uv = flipUV(final_uv);
        
        if (dir.y > 0.0) {
            sampled_color = IMG_NORM_PIXEL(poleTop, final_uv);
        } else {
            sampled_color = IMG_NORM_PIXEL(poleBot, final_uv);
        }
    }

    // Preserve the original input alpha
    isf_FragColor = sampled_color;
}