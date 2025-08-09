/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "Procedural geometry construction using vertex index",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Procedural", "Animation" ],
  "INPUTS": [
    {
      "NAME": "construction_type",
      "TYPE": "long",
      "VALUES": ["Spiral", "Grid", "Sphere", "Helix", "Flower", "Fractal", "Mandala"],
      "DEFAULT": 0
    },
    {
      "NAME": "scale_factor",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 5.0
    },
    {
      "NAME": "density",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 10.0
    },
    {
      "NAME": "spiral_turns",
      "TYPE": "float",
      "DEFAULT": 5.0,
      "MIN": 0.5,
      "MAX": 20.0
    },
    {
      "NAME": "grid_size",
      "TYPE": "long",
      "DEFAULT": 10,
      "MIN": 2,
      "MAX": 50
    },
    {
      "NAME": "animation_speed",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 5.0
    },
    {
      "NAME": "noise_variation",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "center_offset",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 0.0, 0.0]
    },
    {
      "NAME": "rotation_axis",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 1.0, 0.0]
    },
    {
      "NAME": "use_vertex_colors",
      "TYPE": "bool",
      "DEFAULT": true
    }
  ]
}*/

#define PI 3.14159265359
#define TAU 6.28318530718

// Hash functions for procedural generation
float proc_hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

vec3 proc_hash3(float n) {
    return fract(sin(vec3(n, n + 1.0, n + 2.0)) * vec3(43758.5453, 22578.1459, 19642.3490));
}

float proc_noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float n = i.x + i.y * 157.0 + 113.0 * i.z;
    return mix(mix(mix(proc_hash(n + 0.0), proc_hash(n + 1.0), f.x),
                   mix(proc_hash(n + 157.0), proc_hash(n + 158.0), f.x), f.y),
               mix(mix(proc_hash(n + 113.0), proc_hash(n + 114.0), f.x),
                   mix(proc_hash(n + 270.0), proc_hash(n + 271.0), f.x), f.y), f.z);
}

vec3 proc_hsv_to_rgb(vec3 hsv) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
    return hsv.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y);
}

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    float vertex_id = float(gl_VertexIndex);
    float animated_time = TIME * this_filter.animation_speed;
    
    vec3 new_position = this_filter.center_offset;
    vec3 new_color = vec3(1.0);
    
    if (this_filter.construction_type == 0) { // Spiral
        float t = vertex_id * this_filter.density * 0.1;
        float radius = t * 0.1 * this_filter.scale_factor;
        float angle = t * this_filter.spiral_turns + animated_time;
        
        new_position.x += cos(angle) * radius;
        new_position.z += sin(angle) * radius;
        new_position.y += t * 0.05 * this_filter.scale_factor;
        
        // Color based on angle
        float hue = fract(angle / TAU);
        new_color = proc_hsv_to_rgb(vec3(hue, 0.8, 0.9));
    }
    else if (this_filter.construction_type == 1) { // Grid
        int grid_size = this_filter.grid_size;
        int x = int(vertex_id) % grid_size;
        int z = int(vertex_id) / grid_size;
        
        float fx = float(x) / float(grid_size - 1) - 0.5;
        float fz = float(z) / float(grid_size - 1) - 0.5;
        
        new_position.x += fx * this_filter.scale_factor;
        new_position.z += fz * this_filter.scale_factor;
        
        // Add wave animation
        new_position.y += sin(fx * 10.0 + animated_time) * cos(fz * 10.0 + animated_time) * 0.1 * this_filter.scale_factor;
        
        // Color based on position
        new_color = vec3(fx + 0.5, 0.5, fz + 0.5);
    }
    else if (this_filter.construction_type == 2) { // Sphere
        float phi = acos(1.0 - 2.0 * fract(vertex_id * 0.618034)); // Golden ratio
        float theta = TAU * fract(vertex_id * 0.618034);
        
        float radius = this_filter.scale_factor + sin(animated_time + vertex_id * 0.1) * 0.1;
        
        new_position.x += sin(phi) * cos(theta) * radius;
        new_position.y += cos(phi) * radius;
        new_position.z += sin(phi) * sin(theta) * radius;
        
        // Color based on spherical coordinates
        new_color = proc_hsv_to_rgb(vec3(theta / TAU, sin(phi), 0.8));
    }
    else if (this_filter.construction_type == 3) { // Helix
        float t = vertex_id * this_filter.density * 0.05;
        float radius = this_filter.scale_factor * 0.5;
        float angle = t * this_filter.spiral_turns + animated_time;
        
        new_position.x += cos(angle) * radius;
        new_position.z += sin(angle) * radius;
        new_position.y += t * this_filter.scale_factor * 0.2;
        
        // Add secondary helix
        float angle2 = angle + PI;
        new_position.x += cos(angle2) * radius * 0.5;
        new_position.z += sin(angle2) * radius * 0.5;
        
        new_color = proc_hsv_to_rgb(vec3(fract(t * 0.5), 0.7, 0.9));
    }
    else if (this_filter.construction_type == 4) { // Flower
        float petal_count = 8.0;
        float t = vertex_id * this_filter.density * 0.02;
        float angle = t * TAU + animated_time;
        
        // Rose equation: r = cos(k * θ)
        float k = petal_count * 0.5;
        float radius = abs(cos(k * angle)) * this_filter.scale_factor;
        
        new_position.x += cos(angle) * radius;
        new_position.z += sin(angle) * radius;
        new_position.y += sin(t * 5.0 + animated_time) * 0.1 * this_filter.scale_factor;
        
        // Color based on petals
        float petal_hue = fract(floor(angle * petal_count / TAU) / petal_count);
        new_color = proc_hsv_to_rgb(vec3(petal_hue * 0.3 + 0.1, 0.8, 0.9));
    }
    else if (this_filter.construction_type == 5) { // Fractal
        // Simple fractal pattern using vertex index
        float scale = this_filter.scale_factor;
        vec3 p = vec3(0.0);
        float id = vertex_id;
        
        for (int i = 0; i < 4; i++) {
            float branch = mod(id, 3.0);
            id = floor(id / 3.0);
            
            vec3 offset = vec3(0.0);
            if (branch < 1.0) offset = vec3(1.0, 0.0, 0.0);
            else if (branch < 2.0) offset = vec3(0.0, 1.0, 0.0);
            else offset = vec3(0.0, 0.0, 1.0);
            
            p += offset * scale;
            scale *= 0.5;
        }
        
        new_position += p + sin(vec3(animated_time, animated_time * 1.3, animated_time * 0.7)) * 0.1;
        new_color = normalize(abs(p));
    }
    else if (this_filter.construction_type == 6) { // Mandala
        float layers = 5.0;
        float layer = mod(vertex_id, layers);
        float point_in_layer = floor(vertex_id / layers);
        
        float points_per_layer = layer * 6.0 + 6.0; // More points in outer layers
        float angle = (point_in_layer / points_per_layer) * TAU + animated_time * (layer + 1.0) * 0.1;
        float radius = (layer + 1.0) * this_filter.scale_factor * 0.2;
        
        new_position.x += cos(angle) * radius;
        new_position.z += sin(angle) * radius;
        new_position.y += sin(angle * 3.0 + animated_time) * 0.05 * this_filter.scale_factor;
        
        // Color based on layer and angle
        float hue = fract(layer / layers + angle / TAU * 0.5);
        new_color = proc_hsv_to_rgb(vec3(hue, 0.8 - layer * 0.1, 0.9));
    }
    
    // Add noise variation
    if (this_filter.noise_variation > 0.0) {
        vec3 noise_offset = vec3(
            proc_noise(new_position * 5.0 + vec3(animated_time)),
            proc_noise(new_position * 5.0 + vec3(animated_time, 100.0, 0.0)),
            proc_noise(new_position * 5.0 + vec3(animated_time, 0.0, 100.0))
        ) - 0.5;
        
        new_position += noise_offset * this_filter.noise_variation * this_filter.scale_factor;
    }
    
    // Apply the new position
    position = new_position;
    
    // Set vertex color if requested
    if (this_filter.use_vertex_colors) {
        color.rgb = new_color;
    }
    
    // Calculate normal based on neighboring vertices (simplified)
    vec3 tangent_approx = normalize(cross(new_position, vec3(0.0, 1.0, 0.0)));
    normal = normalize(cross(tangent_approx, normalize(new_position)));
    
    // Set UV coordinates based on construction
    if (this_filter.construction_type <= 1) {
        uv = new_position.xz * 0.5 + 0.5;
    } else {
        float angle = atan(new_position.z, new_position.x);
        float radius = length(new_position.xz);
        uv = vec2(angle / TAU + 0.5, fract(radius));
    }
}