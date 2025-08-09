/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "World bending and non-Euclidean perspective effects",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "World Bending", "Animation" ],
  "INPUTS": [
    {
      "NAME": "bending_type",
      "TYPE": "long",
      "VALUES": ["Fisheye", "Barrel", "Curved World", "Spherical", "Cylindrical", "Hyperbolic"],
      "DEFAULT": 2
    },
    {
      "NAME": "bend_strength",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 5.0
    },
    {
      "NAME": "bend_center",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 0.0, 0.0]
    },
    {
      "NAME": "bend_radius",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 0.1,
      "MAX": 10.0
    },
    {
      "NAME": "horizon_curve",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 2.0
    },
    {
      "NAME": "vertical_curve",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": -2.0,
      "MAX": 2.0
    },
    {
      "NAME": "animation_speed",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 3.0
    },
    {
      "NAME": "oscillate_bending",
      "TYPE": "bool",
      "DEFAULT": false
    },
    {
      "NAME": "perspective_scale",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 3.0
    },
    {
      "NAME": "distortion_falloff",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 5.0
    }
  ]
}*/

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    vec3 relative_pos = position - this_filter.bend_center;
    vec3 bent_position = position;
    
    float bend_amount = this_filter.bend_strength;
    if (this_filter.oscillate_bending) {
        bend_amount *= (sin(TIME * this_filter.animation_speed) + 1.0) * 0.5;
    }
    
    if (this_filter.bending_type == 0) { // Fisheye
        // Fisheye distortion - radial displacement
        float distance = length(relative_pos.xz);
        
        if (distance > 0.001) {
            float distorted_distance = distance * (1.0 + bend_amount * distance * distance / (this_filter.bend_radius * this_filter.bend_radius));
            vec2 direction = relative_pos.xz / distance;
            bent_position.xz = this_filter.bend_center.xz + direction * distorted_distance;
        }
        
        // Apply vertical scaling based on distance
        float scale_factor = 1.0 + bend_amount * distance / this_filter.bend_radius * 0.3;
        bent_position.y = this_filter.bend_center.y + (relative_pos.y) * scale_factor;
    }
    else if (this_filter.bending_type == 1) { // Barrel distortion
        vec2 center_offset = relative_pos.xz;
        float r_squared = dot(center_offset, center_offset);
        float distortion = 1.0 + bend_amount * r_squared / (this_filter.bend_radius * this_filter.bend_radius);
        
        bent_position.xz = this_filter.bend_center.xz + center_offset * distortion;
        
        // Add slight Y curvature
        bent_position.y += bend_amount * r_squared * 0.1;
    }
    else if (this_filter.bending_type == 2) { // Curved World
        // Bend the world along the horizon
        float distance_from_center = length(relative_pos.xz);
        float horizon_bend = bend_amount * this_filter.horizon_curve;
        
        // Apply curvature to Y based on XZ distance
        float curve_amount = distance_from_center * distance_from_center / (this_filter.bend_radius * this_filter.bend_radius);
        bent_position.y += curve_amount * horizon_bend;
        
        // Optional vertical curvature
        if (abs(this_filter.vertical_curve) > 0.001) {
            float vertical_distance = abs(relative_pos.y);
            float vertical_bend = vertical_distance * vertical_distance / (this_filter.bend_radius * this_filter.bend_radius);
            
            if (this_filter.vertical_curve > 0.0) {
                // Curve inward
                bent_position.xz = this_filter.bend_center.xz + relative_pos.xz * (1.0 - vertical_bend * this_filter.vertical_curve * 0.3);
            } else {
                // Curve outward
                bent_position.xz = this_filter.bend_center.xz + relative_pos.xz * (1.0 + vertical_bend * abs(this_filter.vertical_curve) * 0.3);
            }
        }
    }
    else if (this_filter.bending_type == 3) { // Spherical
        // Project onto sphere
        float distance = length(relative_pos);
        
        if (distance > 0.001) {
            float sphere_radius = this_filter.bend_radius;
            
            // Map to spherical coordinates
            vec3 direction = relative_pos / distance;
            float mapped_distance = sphere_radius * atan(distance * bend_amount / sphere_radius);
            
            bent_position = this_filter.bend_center + direction * mapped_distance;
        }
    }
    else if (this_filter.bending_type == 4) { // Cylindrical
        // Bend around Y-axis (vertical cylinder)
        float distance_xz = length(relative_pos.xz);
        
        if (distance_xz > 0.001) {
            float angle = distance_xz * bend_amount / this_filter.bend_radius;
            float radius = this_filter.bend_radius;
            
            vec2 direction_xz = relative_pos.xz / distance_xz;
            
            // Map to cylindrical coordinates
            bent_position.x = this_filter.bend_center.x + sin(angle) * radius * direction_xz.x;
            bent_position.z = this_filter.bend_center.z + sin(angle) * radius * direction_xz.y;
            bent_position.y = relative_pos.y + (radius * (1.0 - cos(angle))) * sign(direction_xz.x);
        }
    }
    else if (this_filter.bending_type == 5) { // Hyperbolic
        // Hyperbolic distortion
        vec3 pos = relative_pos;
        
        // Apply hyperbolic transformation
        float x = pos.x;
        float z = pos.z;
        float hyperbolic_factor = bend_amount / this_filter.bend_radius;
        
        // Hyperbolic coordinates
        float new_x = x / (1.0 + hyperbolic_factor * (x*x + z*z));
        float new_z = z / (1.0 + hyperbolic_factor * (x*x + z*z));
        float new_y = pos.y + hyperbolic_factor * (x*x + z*z) * 0.2;
        
        bent_position = this_filter.bend_center + vec3(new_x, new_y, new_z);
    }
    
    // Apply perspective scaling
    if (this_filter.perspective_scale != 1.0) {
        vec3 scale_pos = bent_position - this_filter.bend_center;
        float distance_factor = length(scale_pos) / this_filter.bend_radius;
        distance_factor = pow(distance_factor, this_filter.distortion_falloff);
        
        float scale = mix(1.0, this_filter.perspective_scale, distance_factor);
        bent_position = this_filter.bend_center + scale_pos * scale;
    }
    
    // Update position
    position = bent_position;
    
    // Approximate normal recalculation based on the bending
    // This is a simplified approach - for accurate normals, finite differences would be needed
    vec3 bent_relative = bent_position - this_filter.bend_center;
    vec3 original_relative = (position - this_filter.bend_center);
    
    if (length(original_relative) > 0.001) {
        // Calculate approximate tangent based on bending direction
        vec3 bend_direction = normalize(bent_relative - original_relative);
        
        // Adjust normal to account for the bending
        normal = normalize(normal + bend_direction * bend_amount * 0.3);
    }
}