/*{
    "DESCRIPTION": "Generates a Domemaster output by projecting a rotated equirectangular image. Rotations, output FOV, and horizontal flip are controllable.",
    "CREDIT": "Edu Meneses + AI Assistant (Gemini)",
    "CATEGORIES": [
        "GENERATOR",
        "3D",
        "DOME",
        "PANORAMIC"
    ],
    "INPUTS": [
        { "NAME": "equirectangularImage", "TYPE": "image", "LABEL": "Equirectangular Input" },
        {
	      "NAME" :"XYZrotate",
	      "TYPE" : "point3D",
	      "DEFAULT" : [0.5, 0.5, 0.5],
	      "MAX" : [1.0, 1.0, 1.0],
	      "MIN" : [0.0, 0.0, 0.0]
	    },
        {
            "NAME": "domemaster_output_fov_degrees",
            "LABEL": "Domemaster Output FOV (degrees)",
            "TYPE": "float",
            "DEFAULT": 180.0,
            "MIN": 1.0,
            "MAX": 360.0
        },
        {
            "NAME": "flipHorizontal",
            "LABEL": "Flip Horizontally (Ext. Surface)",
            "TYPE": "bool",
            "DEFAULT": false
        }
    ]
}*/

#define M_PI 3.14159265359

// Uniforms are implicitly declared from INPUTS
// (flipHorizontal is now also an implicit uniform)

mat3 makeRotationMatrix(vec3 a) // a = (yaw, pitch, roll)
{
    // ... (makeRotationMatrix function remains unchanged) ...
    float cos_ax = cos(a.x); float sin_ax = sin(a.x);
    float cos_ay = cos(a.y); float sin_ay = sin(a.y);
    float cos_az = cos(a.z); float sin_az = sin(a.z);

    mat3 my = mat3(cos(a.x), 0, sin(a.x),  0, 1, 0,  -sin(a.x), 0, cos(a.x)); // Yaw
    mat3 mx = mat3(1, 0, 0,  0, cos(a.y), -sin(a.y),  0, sin(a.y), cos(a.y)); // Pitch
    mat3 mz = mat3(cos(a.z), -sin(a.z), 0,  sin(a.z), cos(a.z), 0,  0,0,1);    // Roll

    return my * mx * mz;
}


void main()
{
    vec2 p_norm_screen = vv_FragNormCoord; // Normalized screen coords [0,1]
    vec2 p_centered = (p_norm_screen - 0.5) * 2.0; // Centered screen coords [-1,1]

    // ADDED: Apply horizontal flip if toggled
    if (flipHorizontal) {
        p_centered.x = -p_centered.x;
    }

    float screen_aspect = RENDERSIZE.x / RENDERSIZE.y;
    if (screen_aspect > 1.0) { // Landscape or square
        p_centered.x *= screen_aspect;
    } else { // Portrait
        p_centered.y /= screen_aspect;
    }

    float dist_from_center = length(p_centered);

    if (dist_from_center > 1.0) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }

    float fisheye_half_fov_rad = (domemaster_output_fov_degrees / 2.0) * (M_PI / 180.0);
    float ray_polar_angle_view = dist_from_center * fisheye_half_fov_rad;
    float ray_azimuth_angle_view = atan(p_centered.y, p_centered.x);

    vec3 ray_dir_view;
    ray_dir_view.x = sin(ray_polar_angle_view) * cos(ray_azimuth_angle_view);
    ray_dir_view.y = sin(ray_polar_angle_view) * sin(ray_azimuth_angle_view);
    ray_dir_view.z = cos(ray_polar_angle_view);

    float roll_angle  = (XYZrotate.z - 0.5) * 2.0 * M_PI;
    float yaw_angle   = XYZrotate.x * 2.0 * M_PI;
    float pitch_angle = XYZrotate.y * 2.0 * M_PI;

    vec3 rotation_euler_angles = vec3(yaw_angle, pitch_angle, roll_angle);
    mat3 camera_to_world_rotation_matrix = makeRotationMatrix(rotation_euler_angles);

    vec3 ray_dir_world = camera_to_world_rotation_matrix * ray_dir_view;
    vec3 norm_ray_dir_world = normalize(ray_dir_world);

    float longitude = atan(norm_ray_dir_world.x, norm_ray_dir_world.z);
    float latitude  = asin(norm_ray_dir_world.y);

    float u = longitude / (2.0 * M_PI) + 0.5;
    float v = 0.5 - latitude / M_PI;

    vec2 equirect_uv = vec2(u, v);
    vec4 sampled_color = texture(equirectangularImage, equirect_uv);
    gl_FragColor = sampled_color;
}