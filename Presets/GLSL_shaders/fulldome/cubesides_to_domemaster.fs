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
        {
            "NAME": "rotate_x",
            "LABEL": "Rotate X (0-1, Yaw)",
            "TYPE": "float",
            "DEFAULT": 0.5,
            "MIN": 0.0,
            "MAX": 1.0
        },
        {
            "NAME": "rotate_y",
            "LABEL": "Rotate Y (0-1, Pitch)",
            "TYPE": "float",
            "DEFAULT": 0.5,
            "MIN": 0.0,
            "MAX": 1.0
        },
        {
            "NAME": "rotate_z",
            "LABEL": "Rotate Z (0-1, Roll)",
            "TYPE": "float",
            "DEFAULT": 0.5,
            "MIN": 0.0,
            "MAX": 1.0
        },
        {
            "NAME": "domemaster_output_fov_degrees",
            "LABEL": "Domemaster Output FOV (degrees)",
            "TYPE": "float",
            "DEFAULT": 180.0,
            "MIN": 1.0,
            "MAX": 360.0
        }
    ]
}*/

#define M_PI 3.14159265359

// Uniforms are implicitly declared from INPUTS

// Expects angles for Yaw (around Y), Pitch (around X), Roll (around Z)
// The matrix constructed by this function seems to be for a Y'', X', Z order of intrinsic rotations
// or an extrinsic Z, X, Y order.
// Specifically, if a = (yaw, pitch, roll):
// m11 = cos(yaw)cos(roll) - sin(yaw)cos(pitch)sin(roll)
// m12 = -cos(yaw)sin(roll) - sin(yaw)cos(pitch)cos(roll)
// m13 = sin(yaw)sin(pitch)
// m21 = sin(yaw)cos(roll) + cos(yaw)cos(pitch)sin(roll)
// m22 = -sin(yaw)sin(roll) + cos(yaw)cos(pitch)cos(roll)
// m23 = -cos(yaw)sin(pitch)
// m31 = sin(pitch)sin(roll)
// m32 = sin(pitch)cos(roll)
// m33 = cos(pitch)
mat3 makeRotationMatrix(vec3 a)
{
    float cos_ax = cos(a.x); float sin_ax = sin(a.x); // Yaw components
    float cos_ay = cos(a.y); float sin_ay = sin(a.y); // Pitch components
    float cos_az = cos(a.z); float sin_az = sin(a.z); // Roll components

    return mat3(
        cos_ax * cos_az - sin_ax * cos_ay * sin_az,
        -cos_ax * sin_az - sin_ax * cos_ay * cos_az,
        sin_ax * sin_ay,
        sin_ax * cos_az + cos_ax * cos_ay * sin_az,
        -sin_ax * sin_az + cos_ax * cos_ay * cos_az,
        -cos_ax * sin_ay,
        sin_ay * sin_az,
        sin_ay * cos_az,
        cos_ay
    );
}

void main()
{
    vec2 p_norm_screen = vv_FragNormCoord;
    vec2 p_centered = (p_norm_screen - 0.5) * 2.0;

    float screen_aspect = RENDERSIZE.x / RENDERSIZE.y;
    if (screen_aspect > 1.0) { p_centered.x *= screen_aspect; }
    else { p_centered.y /= screen_aspect; }

    float dist_from_center = length(p_centered);

    if (dist_from_center > 1.0) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    float fisheye_half_fov_rad = (domemaster_output_fov_degrees / 2.0) * (M_PI / 180.0);
    float ray_polar_angle = dist_from_center * fisheye_half_fov_rad;
    float ray_azimuth_angle = atan(p_centered.y, p_centered.x);

    vec3 ray_dir_world;
    ray_dir_world.x = sin(ray_polar_angle) * cos(ray_azimuth_angle);
    ray_dir_world.y = sin(ray_polar_angle) * sin(ray_azimuth_angle);
    ray_dir_world.z = cos(ray_polar_angle);

    // Calculate Yaw, Pitch, and Roll angles from inputs
    float phi_content = rotate_x * 2.0 * M_PI;   // Yaw (0-1 -> 0-360 degrees)
    float psi_content = rotate_y * M_PI;         // Pitch (0-1 -> 0-180 degrees)
    float manual_roll_angle = rotate_z * 2.0 * M_PI; // Manual Roll (0-1 -> 0-360 degrees)

    // Create rotation matrix using Yaw, Pitch, and manual Roll
    vec3 rotation_euler_angles = vec3(phi_content, psi_content, manual_roll_angle);
    mat3 content_rotation_matrix = makeRotationMatrix(rotation_euler_angles);
    mat3 inverse_content_rotation_matrix = transpose(content_rotation_matrix);

    vec3 local_ray_dir = inverse_content_rotation_matrix * ray_dir_world;

    // --- Manual Cubemap Sampling ---
    vec3 v = local_ray_dir;
    vec2 sc_tc; // S, T coords on face, range [-1, 1]
    vec4 sampled_color = vec4(0.0, 0.0, 0.0, 0.0); // Default to transparent black
    vec2 final_uv; // Final UV in [0,1] range

    float abs_x = abs(v.x);
    float abs_y = abs(v.y);
    float abs_z = abs(v.z);

    #define CALCULATE_FINAL_UV(SC_TC) vec2(SC_TC.x * 0.5 + 0.5, 0.5 - SC_TC.y * 0.5)

    if (abs_x >= abs_y && abs_x >= abs_z) { // Major axis X
        if (v.x > 0.0) { // POSITIVE_X
            sc_tc = vec2(-v.z / abs_x, -v.y / abs_x);
            final_uv = CALCULATE_FINAL_UV(sc_tc);
            sampled_color = texture(facePosX, final_uv);
        } else { // NEGATIVE_X
            sc_tc = vec2(v.z / abs_x, -v.y / abs_x);
            final_uv = CALCULATE_FINAL_UV(sc_tc);
            sampled_color = texture(faceNegX, final_uv);
        }
    } else if (abs_y >= abs_x && abs_y >= abs_z) { // Major axis Y
        if (v.y > 0.0) { // POSITIVE_Y (Top)
            sc_tc = vec2(v.x / abs_y, v.z / abs_y);
            final_uv = CALCULATE_FINAL_UV(sc_tc);
            sampled_color = texture(facePosY, final_uv);
        } else { // NEGATIVE_Y (Bottom)
            sc_tc = vec2(v.x / abs_y, -v.z / abs_y);
            final_uv = CALCULATE_FINAL_UV(sc_tc);
            sampled_color = texture(faceNegY, final_uv);
        }
    } else { // Major axis Z
        if (v.z > 0.0) { // POSITIVE_Z (Front)
            sc_tc = vec2(v.x / abs_z, -v.y / abs_z);
            final_uv = CALCULATE_FINAL_UV(sc_tc);
            sampled_color = texture(facePosZ, final_uv);
        } else { // NEGATIVE_Z (Back)
            sc_tc = vec2(-v.x / abs_z, -v.y / abs_z);
            final_uv = CALCULATE_FINAL_UV(sc_tc);
            sampled_color = texture(faceNegZ, final_uv);
        }
    }

    gl_FragColor = sampled_color;
}