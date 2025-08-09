/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "Gravity attractor effects with multiple attractor types",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Physics", "Animation" ],
  "INPUTS": [
    {
      "NAME": "attractor_type",
      "TYPE": "long",
      "VALUES": ["Point", "Line", "Plane", "Multiple Points", "Grid", "Cube", "Sphere"],
      "DEFAULT": 0
    },
    {
      "NAME": "gravity_strength",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 10.0
    },
    {
      "NAME": "attractor_position",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 1.0, 0.0]
    },
    {
      "NAME": "falloff_type",
      "TYPE": "long",
      "VALUES": ["Linear", "Inverse Square", "Exponential", "Constant"],
      "DEFAULT": 1
    },
    {
      "NAME": "max_distance",
      "TYPE": "float",
      "DEFAULT": 5.0,
      "MIN": 0.1,
      "MAX": 20.0
    },
    {
      "NAME": "grid_size",
      "TYPE": "long",
      "DEFAULT": 3,
      "MIN": 2,
      "MAX": 10
    },
    {
      "NAME": "cube_size",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 0.5,
      "MAX": 5.0
    },
    {
      "NAME": "sphere_radius",
      "TYPE": "float",
      "DEFAULT": 1.5,
      "MIN": 0.5,
      "MAX": 5.0
    },
    {
      "NAME": "animation_speed",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 5.0
    },
    {
      "NAME": "oscillate_attractors",
      "TYPE": "bool",
      "DEFAULT": false
    },
    {
      "NAME": "damping",
      "TYPE": "float",
      "DEFAULT": 0.9,
      "MIN": 0.1,
      "MAX": 1.0
    }
  ]
}*/

#define PI 3.14159265359

// Hash function for generating multiple attractors
float grav_hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

vec3 grav_hash3(float n) {
    return fract(sin(vec3(n, n + 1.0, n + 2.0)) * vec3(43758.5453, 22578.1459, 19642.3490));
}

// Calculate gravity force based on distance and falloff type
float grav_calculate_force(float distance, int falloff_type, float strength, float max_dist) {
    if (distance >= max_dist) return 0.0;
    
    float normalized_distance = distance / max_dist;
    float force = 0.0;
    
    if (falloff_type == 0) { // Linear
        force = (1.0 - normalized_distance) * strength;
    }
    else if (falloff_type == 1) { // Inverse Square
        force = strength / (1.0 + normalized_distance * normalized_distance * 10.0);
    }
    else if (falloff_type == 2) { // Exponential
        force = strength * exp(-normalized_distance * 3.0);
    }
    else { // Constant
        force = strength;
    }
    
    return force;
}

// Find closest point on a line segment
vec3 grav_closest_point_on_line(vec3 point, vec3 line_start, vec3 line_end) {
    vec3 line_vec = line_end - line_start;
    float line_length = length(line_vec);
    
    if (line_length < 0.001) return line_start;
    
    vec3 line_dir = line_vec / line_length;
    float t = dot(point - line_start, line_dir);
    t = clamp(t, 0.0, line_length);
    
    return line_start + line_dir * t;
}

// Find closest point on a plane
vec3 grav_closest_point_on_plane(vec3 point, vec3 plane_center, vec3 plane_normal) {
    vec3 to_point = point - plane_center;
    float distance_to_plane = dot(to_point, plane_normal);
    return point - plane_normal * distance_to_plane;
}

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    vec3 gravity_force = vec3(0.0);
    vec3 animated_attractor_pos = this_filter.attractor_position;
    
    if (this_filter.oscillate_attractors) {
        animated_attractor_pos += vec3(
            sin(TIME * this_filter.animation_speed) * 0.5,
            cos(TIME * this_filter.animation_speed * 1.3) * 0.3,
            sin(TIME * this_filter.animation_speed * 0.7) * 0.4
        );
    }
    
    if (this_filter.attractor_type == 0) { // Point attractor
        vec3 to_attractor = animated_attractor_pos - position;
        float distance = length(to_attractor);
        
        if (distance > 0.001) {
            vec3 direction = to_attractor / distance;
            float force = grav_calculate_force(distance, this_filter.falloff_type, 
                                             this_filter.gravity_strength, this_filter.max_distance);
            gravity_force = direction * force;
        }
    }
    else if (this_filter.attractor_type == 1) { // Line attractor
        vec3 line_start = animated_attractor_pos - vec3(1.0, 0.0, 0.0);
        vec3 line_end = animated_attractor_pos + vec3(1.0, 0.0, 0.0);
        
        vec3 closest_point = grav_closest_point_on_line(position, line_start, line_end);
        vec3 to_line = closest_point - position;
        float distance = length(to_line);
        
        if (distance > 0.001) {
            vec3 direction = to_line / distance;
            float force = grav_calculate_force(distance, this_filter.falloff_type,
                                             this_filter.gravity_strength, this_filter.max_distance);
            gravity_force = direction * force;
        }
    }
    else if (this_filter.attractor_type == 2) { // Plane attractor
        vec3 plane_normal = vec3(0.0, 1.0, 0.0);
        vec3 closest_point = grav_closest_point_on_plane(position, animated_attractor_pos, plane_normal);
        vec3 to_plane = closest_point - position;
        float distance = length(to_plane);
        
        if (distance > 0.001) {
            vec3 direction = to_plane / distance;
            float force = grav_calculate_force(distance, this_filter.falloff_type,
                                             this_filter.gravity_strength, this_filter.max_distance);
            gravity_force = direction * force;
        }
    }
    else if (this_filter.attractor_type == 3) { // Multiple random points
        int num_attractors = 5;
        
        for (int i = 0; i < num_attractors; i++) {
            vec3 attractor_offset = (grav_hash3(float(i)) - 0.5) * 4.0;
            vec3 attractor_pos = animated_attractor_pos + attractor_offset;
            
            vec3 to_attractor = attractor_pos - position;
            float distance = length(to_attractor);
            
            if (distance > 0.001) {
                vec3 direction = to_attractor / distance;
                float force = grav_calculate_force(distance, this_filter.falloff_type,
                                                 this_filter.gravity_strength * 0.3, this_filter.max_distance);
                gravity_force += direction * force;
            }
        }
    }
    else if (this_filter.attractor_type == 4) { // Grid attractors
        int grid_size = this_filter.grid_size;
        float spacing = this_filter.cube_size / float(grid_size - 1);
        vec3 grid_start = animated_attractor_pos - vec3(this_filter.cube_size * 0.5);
        
        for (int x = 0; x < grid_size; x++) {
            for (int y = 0; y < grid_size; y++) {
                for (int z = 0; z < grid_size; z++) {
                    if (x >= 10 || y >= 10 || z >= 10) break; // Safety limit
                    
                    vec3 grid_pos = grid_start + vec3(float(x), float(y), float(z)) * spacing;
                    vec3 to_attractor = grid_pos - position;
                    float distance = length(to_attractor);
                    
                    if (distance > 0.001) {
                        vec3 direction = to_attractor / distance;
                        float force = grav_calculate_force(distance, this_filter.falloff_type,
                                                         this_filter.gravity_strength * 0.1, this_filter.max_distance);
                        gravity_force += direction * force;
                    }
                }
            }
        }
    }
    else if (this_filter.attractor_type == 5) { // Cube vertices
        float half_size = this_filter.cube_size * 0.5;
        vec3 cube_vertices[8];
        
        cube_vertices[0] = animated_attractor_pos + vec3(-half_size, -half_size, -half_size);
        cube_vertices[1] = animated_attractor_pos + vec3( half_size, -half_size, -half_size);
        cube_vertices[2] = animated_attractor_pos + vec3(-half_size,  half_size, -half_size);
        cube_vertices[3] = animated_attractor_pos + vec3( half_size,  half_size, -half_size);
        cube_vertices[4] = animated_attractor_pos + vec3(-half_size, -half_size,  half_size);
        cube_vertices[5] = animated_attractor_pos + vec3( half_size, -half_size,  half_size);
        cube_vertices[6] = animated_attractor_pos + vec3(-half_size,  half_size,  half_size);
        cube_vertices[7] = animated_attractor_pos + vec3( half_size,  half_size,  half_size);
        
        for (int i = 0; i < 8; i++) {
            vec3 to_attractor = cube_vertices[i] - position;
            float distance = length(to_attractor);
            
            if (distance > 0.001) {
                vec3 direction = to_attractor / distance;
                float force = grav_calculate_force(distance, this_filter.falloff_type,
                                                 this_filter.gravity_strength * 0.2, this_filter.max_distance);
                gravity_force += direction * force;
            }
        }
    }
    else if (this_filter.attractor_type == 6) { // Sphere surface points
        int num_points = 20; // Approximate icosphere points
        
        for (int i = 0; i < num_points; i++) {
            float phi = acos(1.0 - 2.0 * fract(float(i) * 0.618034));
            float theta = 2.0 * PI * fract(float(i) * 0.618034);
            
            vec3 sphere_point = animated_attractor_pos + this_filter.sphere_radius * vec3(
                sin(phi) * cos(theta),
                cos(phi),
                sin(phi) * sin(theta)
            );
            
            vec3 to_attractor = sphere_point - position;
            float distance = length(to_attractor);
            
            if (distance > 0.001) {
                vec3 direction = to_attractor / distance;
                float force = grav_calculate_force(distance, this_filter.falloff_type,
                                                 this_filter.gravity_strength * 0.1, this_filter.max_distance);
                gravity_force += direction * force;
            }
        }
    }
    
    // Apply damping to prevent overshooting
    gravity_force *= this_filter.damping;
    
    // Apply the gravity force as position displacement
    position += gravity_force * 0.01; // Scale down for stable animation
    
    // Visualize force strength in vertex color
    float force_magnitude = length(gravity_force);
    color.rgb = mix(color.rgb, vec3(force_magnitude * 0.5, 0.2, 1.0 - force_magnitude * 0.3), 0.5);
}