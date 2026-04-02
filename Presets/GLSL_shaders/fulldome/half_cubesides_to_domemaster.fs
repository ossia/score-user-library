/*{
    "DESCRIPTION": "Optimized single-pass Domemaster. Maps raw 2:1 images to top/bottom halves, rotating bottom 180. Includes API-level input flips.",
    "CREDIT": "Edu Meneses + AI Assistant (Gemini)",
    "CATEGORIES": [
        "GENERATOR",
        "3D",
        "DOME"
    ],
    "INPUTS": [
        { "NAME": "facePosX_Top", "TYPE": "image", "LABEL": "+X Side (Top Image)" },
        { "NAME": "facePosX_Bot", "TYPE": "image", "LABEL": "+X Side (Bottom Image - 180 Rot)" },
        { "NAME": "faceNegX_Top", "TYPE": "image", "LABEL": "-X Side (Top Image)" },
        { "NAME": "faceNegX_Bot", "TYPE": "image", "LABEL": "-X Side (Bottom Image - 180 Rot)" },
        { "NAME": "facePosZ_Top", "TYPE": "image", "LABEL": "+Z Side (Front Top)" },
        { "NAME": "facePosZ_Bot", "TYPE": "image", "LABEL": "+Z Side (Front Bottom - 180 Rot)" },
        { "NAME": "faceNegZ_Top", "TYPE": "image", "LABEL": "-Z Side (Back Top)" },
        { "NAME": "faceNegZ_Bot", "TYPE": "image", "LABEL": "-Z Side (Back Bottom - 180 Rot)" },
        { "NAME": "facePosY", "TYPE": "image", "LABEL": "+Y Pole (Zenith/Ceiling)" },
        { "NAME": "faceNegY", "TYPE": "image", "LABEL": "-Y Pole (Nadir/Floor)" },
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

    // --- Target Face Selection & Spatial Mapping ---
    vec3 v_abs = abs(local_ray_dir);
    vec2 sc_tc, final_uv;
    vec4 sampled_color = vec4(0.0);

    // Helper macro to calculate base UVs from cube coordinates
    #define CALC_FINAL_UV(coord) ((coord * vec2(-1.0, -1.0) + 1.0) * 0.5)

    if (v_abs.x >= v_abs.y && v_abs.x >= v_abs.z) { // Hit X Axis (Sides)
        if (local_ray_dir.x > 0.0) { // +X Right
            sc_tc = vec2(-local_ray_dir.z, -local_ray_dir.y) / v_abs.x;
            final_uv = CALC_FINAL_UV(sc_tc);
            if (final_uv.y >= 0.5) {
                sampled_color = IMG_NORM_PIXEL(facePosX_Top, flipUV(vec2(final_uv.x, (final_uv.y - 0.5) * 2.0)));
                sampled_color.rgb *= alpha1;
            } else {
                sampled_color = IMG_NORM_PIXEL(facePosX_Bot, flipUV(vec2(1.0 - final_uv.x, 1.0 - (final_uv.y * 2.0))));
                sampled_color.rgb *= alpha2;
            }
        } else { // -X Left
            sc_tc = vec2(local_ray_dir.z, -local_ray_dir.y) / v_abs.x;
            final_uv = CALC_FINAL_UV(sc_tc);
            if (final_uv.y >= 0.5) {
                sampled_color = IMG_NORM_PIXEL(faceNegX_Top, flipUV(vec2(final_uv.x, (final_uv.y - 0.5) * 2.0)));
                sampled_color.rgb *= alpha1;
            } else {
                sampled_color = IMG_NORM_PIXEL(faceNegX_Bot, flipUV(vec2(1.0 - final_uv.x, 1.0 - (final_uv.y * 2.0))));
                sampled_color.rgb *= alpha2;
            }
        }
    } else if (v_abs.y >= v_abs.z) { // Hit Y Axis (Top/Bottom Poles)
        if (local_ray_dir.y > 0.0) { // +Y Top Pole
            sc_tc = vec2(local_ray_dir.x, local_ray_dir.z) / v_abs.y;
            final_uv = CALC_FINAL_UV(sc_tc);
            sampled_color = IMG_NORM_PIXEL(facePosY, flipUV(final_uv));
        } else { // -Y Bottom Pole
            sc_tc = vec2(local_ray_dir.x, -local_ray_dir.z) / v_abs.y;
            final_uv = CALC_FINAL_UV(sc_tc);
            sampled_color = IMG_NORM_PIXEL(faceNegY, flipUV(final_uv));
        }
    } else { // Hit Z Axis (Sides)
        if (local_ray_dir.z > 0.0) { // +Z Front
            sc_tc = vec2(local_ray_dir.x, -local_ray_dir.y) / v_abs.z;
            final_uv = CALC_FINAL_UV(sc_tc);
            if (final_uv.y >= 0.5) {
                sampled_color = IMG_NORM_PIXEL(facePosZ_Top, flipUV(vec2(final_uv.x, (final_uv.y - 0.5) * 2.0)));
                sampled_color.rgb *= alpha1;
            } else {
                sampled_color = IMG_NORM_PIXEL(facePosZ_Bot, flipUV(vec2(1.0 - final_uv.x, 1.0 - (final_uv.y * 2.0))));
                sampled_color.rgb *= alpha2;
            }
        } else { // -Z Back
            sc_tc = vec2(-local_ray_dir.x, -local_ray_dir.y) / v_abs.z;
            final_uv = CALC_FINAL_UV(sc_tc);
            if (final_uv.y >= 0.5) {
                sampled_color = IMG_NORM_PIXEL(faceNegZ_Top, flipUV(vec2(final_uv.x, (final_uv.y - 0.5) * 2.0)));
                sampled_color.rgb *= alpha1;
            } else {
                sampled_color = IMG_NORM_PIXEL(faceNegZ_Bot, flipUV(vec2(1.0 - final_uv.x, 1.0 - (final_uv.y * 2.0))));
                sampled_color.rgb *= alpha2;
            }
        }
    }

    isf_FragColor = sampled_color;
}