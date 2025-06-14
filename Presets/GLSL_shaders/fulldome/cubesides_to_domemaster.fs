/*{
    "DESCRIPTION": "Generates a Domemaster output by projecting a rotated cubemap (6 input images). Rotations and output FOV are controllable.",
    "CREDIT": "Edu Meneses + AI Assistant (Gemini)",
    "CATEGORIES": [
        "GENERATOR",
        "3D",
        "DOME"
    ],
    "INPUTS": [
        { "NAME": "facePosX", "TYPE": "image", "LABEL": "Face +X (Right)" },
        { "NAME": "faceNegX", "TYPE": "image", "LABEL": "Face -X (Left)" },
        { "NAME": "facePosY", "TYPE": "image", "LABEL": "Face +Y (Top)" },
        { "NAME": "faceNegY", "TYPE": "image", "LABEL": "Face -Y (Bottom)" },
        { "NAME": "facePosZ", "TYPE": "image", "LABEL": "Face +Z (Front)" },
        { "NAME": "faceNegZ", "TYPE": "image", "LABEL": "Face -Z (Back)" },
        { "NAME": "rotate_x", "LABEL": "Rotate X (0-1, Yaw)", "TYPE": "float", "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "rotate_y", "LABEL": "Rotate Y (0-1, Pitch)", "TYPE": "float", "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "rotate_z", "LABEL": "Rotate Z (0-1, Roll)", "TYPE": "float", "DEFAULT": 0.5, "MIN": 0.0, "MAX": 1.0 },
        { "NAME": "domemaster_output_fov_degrees", "LABEL": "Domemaster Output FOV (degrees)", "TYPE": "float", "DEFAULT": 180.0, "MIN": 1.0, "MAX": 360.0 }
    ]
}*/

// Mathematical constants for clarity and precision.
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

void main() {
    // --- Calculations performed for every fragment ---
    vec2 p_centered = (vv_FragNormCoord - 0.5) * 2.0;

    // Correct for aspect ratio
    float screen_aspect = RENDERSIZE.x / RENDERSIZE.y;
    if (screen_aspect > 1.0) { p_centered.x *= screen_aspect; }
    else { p_centered.y /= screen_aspect; }

    // Create the circular domemaster mask
    float dist_from_center = length(p_centered);
    if (dist_from_center > 1.0) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    // --- Uniform calculations (constant for all fragments) ---
    float yaw   = rotate_x * TWO_PI;
    float pitch = rotate_y * M_PI;
    float roll  = rotate_z * TWO_PI;
    mat3 content_rotation_matrix = makeRotationMatrix(vec3(yaw, pitch, roll));
    mat3 inverse_content_rotation_matrix = transpose(content_rotation_matrix);
    float fisheye_half_fov_rad = domemaster_output_fov_degrees * (M_PI / 360.0);

    // --- Per-fragment calculations continued ---
    float ray_polar_angle = dist_from_center * fisheye_half_fov_rad;
    float ray_azimuth_angle = atan(p_centered.y, p_centered.x);

    vec3 ray_dir_world = vec3(
        sin(ray_polar_angle) * cos(ray_azimuth_angle),
        sin(ray_polar_angle) * sin(ray_azimuth_angle),
        cos(ray_polar_angle)
    );
    vec3 local_ray_dir = inverse_content_rotation_matrix * ray_dir_world;

    // --- Cubemap face selection and sampling ---
    vec3 v_abs = abs(local_ray_dir);
    vec4 sampled_color;
    vec2 sc_tc;    // Raw [-1, 1] texture coordinates on a cube face
    vec2 final_uv; // Final [0, 1] texture coordinates

    // This universal formula converts [-1, 1] coordinates to final [0, 1] UVs,
    // applying the required vertical flip that was used in the original shader.
    #define CALC_FINAL_UV(coord) ((coord * vec2(1.0, -1.0) + 1.0) * 0.5)

    // The branching logic is optimized, but the sc_tc calculations are now
    // identical to the original shader to ensure correct face orientation.
    if (v_abs.x >= v_abs.y && v_abs.x >= v_abs.z) { // Major axis: X
        if (local_ray_dir.x > 0.0) { // Positive X
            sc_tc = vec2(-local_ray_dir.z, -local_ray_dir.y) / v_abs.x;
            final_uv = CALC_FINAL_UV(sc_tc);
            sampled_color = texture(facePosX, final_uv);
        } else { // Negative X
            sc_tc = vec2(local_ray_dir.z, -local_ray_dir.y) / v_abs.x;
            final_uv = CALC_FINAL_UV(sc_tc);
            sampled_color = texture(faceNegX, final_uv);
        }
    } else if (v_abs.y >= v_abs.z) { // Major axis: Y
        if (local_ray_dir.y > 0.0) { // Positive Y
            sc_tc = vec2(local_ray_dir.x, local_ray_dir.z) / v_abs.y;
            final_uv = CALC_FINAL_UV(sc_tc);
            sampled_color = texture(facePosY, final_uv);
        } else { // Negative Y
            sc_tc = vec2(local_ray_dir.x, -local_ray_dir.z) / v_abs.y;
            final_uv = CALC_FINAL_UV(sc_tc);
            sampled_color = texture(faceNegY, final_uv);
        }
    } else { // Major axis: Z
        if (local_ray_dir.z > 0.0) { // Positive Z
            sc_tc = vec2(local_ray_dir.x, -local_ray_dir.y) / v_abs.z;
            final_uv = CALC_FINAL_UV(sc_tc);
            sampled_color = texture(facePosZ, final_uv);
        } else { // Negative Z
            sc_tc = vec2(-local_ray_dir.x, -local_ray_dir.y) / v_abs.z;
            final_uv = CALC_FINAL_UV(sc_tc);
            sampled_color = texture(faceNegZ, final_uv);
        }
    }
    gl_FragColor = sampled_color;
}