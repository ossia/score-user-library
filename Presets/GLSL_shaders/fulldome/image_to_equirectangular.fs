/*{
    "DESCRIPTION": "Overlays an image onto an equirectangular projection with true spherical distortion. Allows 3D positioning, rotation, and scaling of the overlay on the sphere. Surrounding space is transparent or shows a base equirectangular image.",
    "CREDIT": "Edu Meneses + AI Assistant (Gemini)",
    "CATEGORIES": [
        "EFFECT",
        "TRANSFORM",
        "3D",
        "COMPOSITE"
    ],
    "INPUTS": [
        { "NAME": "baseImage", "TYPE": "image", "LABEL": "Background Equirectangular (Optional)" },
        { "NAME": "overlayImage", "TYPE": "image", "LABEL": "Overlay Image" },
        { "NAME": "centerLon", "TYPE": "float", "LABEL": "Center Longitude (deg)", "DEFAULT": 0.0, "MIN": -180.0, "MAX": 180.0, "GROUP": "Overlay Transform" },
        { "NAME": "centerLat", "TYPE": "float", "LABEL": "Center Latitude (deg)", "DEFAULT": 0.0, "MIN": -90.0, "MAX": 90.0, "GROUP": "Overlay Transform" },
        { "NAME": "overlayWidth", "TYPE": "float", "LABEL": "Overlay Width (deg)", "DEFAULT": 90.0, "MIN": 0.1, "MAX": 360.0, "GROUP": "Overlay Transform" },
        { "NAME": "overlayHeight", "TYPE": "float", "LABEL": "Overlay Height (deg)", "DEFAULT": 90.0, "MIN": 0.1, "MAX": 180.0, "GROUP": "Overlay Transform" }, 
        { "NAME": "rotation", "TYPE": "float", "LABEL": "Rotation (deg)", "DEFAULT": 0.0, "MIN": -360.0, "MAX": 360.0, "GROUP": "Overlay Transform" },
        { "NAME": "overlayAlpha", "TYPE": "float", "LABEL": "Overlay Alpha", "DEFAULT": 1.0, "MIN": 0.0, "MAX": 1.0, "GROUP": "Overlay Appearance" }
    ]
}*/

const float PI = 3.141592653589793;
const float TWO_PI = 2.0 * PI;
const float HALF_PI = PI / 2.0;
const float EPSILON = 0.00001; // Small value to prevent division by zero

// Rotates vector 'v' around axis 'k' by 'angle' (in radians)
// Assumes k is a unit vector.
vec3 rotate_vector_around_axis(vec3 v, vec3 k, float angle) {
    float cos_angle = cos(angle);
    float sin_angle = sin(angle);
    return v * cos_angle + cross(k, v) * sin_angle + k * dot(k, v) * (1.0 - cos_angle);
}

void main() {
    // equirectUV.x (longitude): 0.0 (-180 deg) to 1.0 (+180 deg)
    // equirectUV.y (latitude):  0.0 (-90 deg) to 1.0 (+90 deg)
    vec2 equirectUV = vv_FragNormCoord;

    // 1. Convert current equirectangular UV to a 3D direction vector (P_target_world)
    float lon_rad_target = (equirectUV.x - 0.5) * TWO_PI;  // Range: -PI to PI
    float lat_rad_target = (equirectUV.y - 0.5) * PI;    // Range: -PI/2 to PI/2
    
    vec3 P_target_world;
    P_target_world.y = sin(lat_rad_target);
    float cos_lat_target = cos(lat_rad_target);
    P_target_world.x = cos_lat_target * sin(lon_rad_target);
    P_target_world.z = cos_lat_target * cos(lon_rad_target);

    // 2. Define Overlay's Frame on the Sphere
    // a. Overlay's center direction (forward vector)
    float centerLon_rad = radians(centerLon);
    float centerLat_rad = radians(centerLat);
    
    vec3 overlay_forward_world;
    overlay_forward_world.y = sin(centerLat_rad);
    float cos_center_lat = cos(centerLat_rad);
    overlay_forward_world.x = cos_center_lat * sin(centerLon_rad);
    overlay_forward_world.z = cos_center_lat * cos(centerLon_rad);
    overlay_forward_world = normalize(overlay_forward_world); // Ensure it's unit length

    // b. Initial "up" and "right" vectors for the overlay
    vec3 tentative_up_world = vec3(0.0, 1.0, 0.0); // World Y-axis
    // If overlay center is too close to the poles, world Y is not a good tentative up.
    if (abs(dot(overlay_forward_world, tentative_up_world)) > 0.999) {
        tentative_up_world = vec3(0.0, 0.0, 1.0); // Use world Z-axis instead
        if (abs(dot(overlay_forward_world, tentative_up_world)) > 0.999) { // If also aligned with Z (e.g. forward is 0,0,1)
             tentative_up_world = vec3(1.0, 0.0, 0.0); // Use world X-axis
        }
    }

    vec3 overlay_right_initial_world = normalize(cross(tentative_up_world, overlay_forward_world));
    vec3 overlay_up_initial_world = normalize(cross(overlay_forward_world, overlay_right_initial_world));

    // c. Apply overlay rotation around its forward vector
    float overlay_rotation_rad = radians(rotation);
    vec3 overlay_right_rotated_world = rotate_vector_around_axis(overlay_right_initial_world, overlay_forward_world, overlay_rotation_rad);
    vec3 overlay_up_rotated_world = rotate_vector_around_axis(overlay_up_initial_world, overlay_forward_world, overlay_rotation_rad);

    // 3. Transform P_target_world into Overlay's Local Coordinate System
    // P_in_overlay_coords.x is projection onto overlay's right
    // P_in_overlay_coords.y is projection onto overlay's up
    // P_in_overlay_coords.z is projection onto overlay's forward
    vec3 P_in_overlay_coords;
    P_in_overlay_coords.x = dot(P_target_world, overlay_right_rotated_world);
    P_in_overlay_coords.y = dot(P_target_world, overlay_up_rotated_world);
    P_in_overlay_coords.z = dot(P_target_world, overlay_forward_world);

    // 4. Convert P_in_overlay_coords to local spherical angles (azimuth, elevation)
    //    and then to UVs for sampling the overlayImage.
    vec2 overlay_uv_to_sample = vec2(2.0, 2.0); // Default to outside [0,1] range
    bool in_overlay_bounds = false;

    float half_width_rad = radians(overlayWidth) / 2.0;
    float half_height_rad = radians(overlayHeight) / 2.0;

    // Check if overlay has valid dimensions and if P_target is in front of the overlay
    if (half_width_rad > EPSILON && half_height_rad > EPSILON && P_in_overlay_coords.z > -EPSILON) { // z > -EPSILON to allow points exactly on the plane
        // local_azimuth: angle in overlay's local XZ plane, from Z (forward) towards X (right)
        float local_azimuth = atan(P_in_overlay_coords.x, P_in_overlay_coords.z); // Range: -PI to PI
        // local_elevation: angle from overlay's local XZ plane towards Y (up)
        float local_elevation = asin(clamp(P_in_overlay_coords.y, -1.0, 1.0)); // Range: -PI/2 to PI/2

        // Check if these angles are within the overlay's defined angular extent
        if (abs(local_azimuth) <= half_width_rad + EPSILON && abs(local_elevation) <= half_height_rad + EPSILON) {
            // Normalize angles to [0,1] UV space for the overlay image
            overlay_uv_to_sample.x = (local_azimuth / half_width_rad) * 0.5 + 0.5;
            overlay_uv_to_sample.y = (local_elevation / half_height_rad) * 0.5 + 0.5;
            in_overlay_bounds = true;
        }
    }
    
    // --- Determine Base Color ---
    vec4 base_color = IMG_NORM_PIXEL(baseImage, equirectUV);

    // --- Determine Overlay Color and Composite ---
    if (in_overlay_bounds && 
        overlay_uv_to_sample.x >= -EPSILON && overlay_uv_to_sample.x <= 1.0 + EPSILON &&
        overlay_uv_to_sample.y >= -EPSILON && overlay_uv_to_sample.y <= 1.0 + EPSILON) {
        
        // Clamp UVs strictly to [0,1] for sampling to avoid potential issues with texture repeat/clamp at edges.
        vec2 clamped_overlay_uv = clamp(overlay_uv_to_sample, 0.0, 1.0);
        vec4 overlay_color_sampled = IMG_NORM_PIXEL(overlayImage, clamped_overlay_uv);
        overlay_color_sampled.a *= overlayAlpha; 

        // Standard alpha blending
        float composite_alpha = overlay_color_sampled.a + base_color.a * (1.0 - overlay_color_sampled.a);
        vec3 composite_rgb;
        if (composite_alpha > EPSILON) {
            composite_rgb = (overlay_color_sampled.rgb * overlay_color_sampled.a + 
                             base_color.rgb * base_color.a * (1.0 - overlay_color_sampled.a)) / composite_alpha;
        } else {
            composite_rgb = base_color.rgb; 
        }
        gl_FragColor = vec4(composite_rgb, composite_alpha);
    } else {
        gl_FragColor = base_color;
    }
}
