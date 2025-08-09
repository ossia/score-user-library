/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "Procedural terrain generation",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Terrain", "Animation" ],
  "INPUTS": [
    {
      "NAME": "terrain_height",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 10.0
    },
    {
      "NAME": "terrain_scale",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 10.0
    },
    {
      "NAME": "terrain_type",
      "TYPE": "long",
      "VALUES": ["Plains", "Hills", "Mountains", "Ridges", "Canyons", "Valleys"],
      "DEFAULT": 1
    },
    {
      "NAME": "octaves",
      "TYPE": "long",
      "DEFAULT": 4,
      "MIN": 1,
      "MAX": 8
    },
    {
      "NAME": "lacunarity",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 1.0,
      "MAX": 4.0
    },
    {
      "NAME": "persistence",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "erosion_factor",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "animate_terrain",
      "TYPE": "bool",
      "DEFAULT": false
    },
    {
      "NAME": "animation_speed",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "height_offset",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": -5.0,
      "MAX": 5.0
    }
  ]
}*/

// Hash function
float terrain_hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453123);
}

// 2D Value noise
float terrain_value_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = terrain_hash(i);
    float b = terrain_hash(i + vec2(1.0, 0.0));
    float c = terrain_hash(i + vec2(0.0, 1.0));
    float d = terrain_hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// 2D Gradient noise (Perlin-like)
vec2 terrain_gradient(vec2 p) {
    float h = terrain_hash(p);
    float angle = h * 6.28318530718;
    return vec2(cos(angle), sin(angle));
}

float terrain_perlin_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(mix(dot(terrain_gradient(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
                   dot(terrain_gradient(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
               mix(dot(terrain_gradient(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
                   dot(terrain_gradient(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
}

// Fractal Brownian Motion
float terrain_fbm(vec2 p, int octaves, float lacunarity, float persistence) {
    float value = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    
    for (int i = 0; i < octaves && i < 8; i++) {
        value += terrain_perlin_noise(p * frequency) * amplitude;
        frequency *= lacunarity;
        amplitude *= persistence;
    }
    
    return value;
}

// Ridged noise
float terrain_ridged_noise(vec2 p, int octaves, float lacunarity, float persistence) {
    float value = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    
    for (int i = 0; i < octaves && i < 8; i++) {
        float n = abs(terrain_perlin_noise(p * frequency));
        n = 1.0 - n;
        n = n * n;
        value += n * amplitude;
        frequency *= lacunarity;
        amplitude *= persistence;
    }
    
    return value;
}

// Turbulence
float terrain_turbulence(vec2 p, int octaves, float lacunarity, float persistence) {
    float value = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    
    for (int i = 0; i < octaves && i < 8; i++) {
        value += abs(terrain_perlin_noise(p * frequency)) * amplitude;
        frequency *= lacunarity;
        amplitude *= persistence;
    }
    
    return value;
}

// Erosion simulation (simplified)
float terrain_apply_erosion(vec2 p, float base_height, float erosion_factor) {
    if (erosion_factor <= 0.0) return base_height;
    
    // Sample neighboring heights for slope calculation
    float h_left = terrain_perlin_noise((p + vec2(-0.01, 0.0)) * 5.0);
    float h_right = terrain_perlin_noise((p + vec2(0.01, 0.0)) * 5.0);
    float h_up = terrain_perlin_noise((p + vec2(0.0, 0.01)) * 5.0);
    float h_down = terrain_perlin_noise((p + vec2(0.0, -0.01)) * 5.0);
    
    // Calculate slope (simplified gradient magnitude)
    float slope = length(vec2(h_right - h_left, h_up - h_down)) * 50.0;
    
    // Erode high-slope areas more
    float erosion = slope * erosion_factor;
    return base_height - erosion * 0.5;
}

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    vec2 terrain_pos = position.xz * this_filter.terrain_scale;
    
    if (this_filter.animate_terrain) {
        terrain_pos += vec2(TIME * this_filter.animation_speed);
    }
    
    float height = 0.0;
    
    if (this_filter.terrain_type == 0) { // Plains
        height = terrain_fbm(terrain_pos, this_filter.octaves, this_filter.lacunarity, this_filter.persistence);
        height = height * 0.3; // Keep it relatively flat
    }
    else if (this_filter.terrain_type == 1) { // Hills
        height = terrain_fbm(terrain_pos, this_filter.octaves, this_filter.lacunarity, this_filter.persistence);
    }
    else if (this_filter.terrain_type == 2) { // Mountains
        float base = terrain_fbm(terrain_pos * 0.5, this_filter.octaves, this_filter.lacunarity, this_filter.persistence);
        float detail = terrain_fbm(terrain_pos * 2.0, this_filter.octaves - 1, this_filter.lacunarity, this_filter.persistence) * 0.5;
        height = base + detail;
        height = height * height; // Square for more dramatic peaks
    }
    else if (this_filter.terrain_type == 3) { // Ridges
        height = terrain_ridged_noise(terrain_pos, this_filter.octaves, this_filter.lacunarity, this_filter.persistence);
    }
    else if (this_filter.terrain_type == 4) { // Canyons
        height = terrain_ridged_noise(terrain_pos, this_filter.octaves, this_filter.lacunarity, this_filter.persistence);
        height = 1.0 - height; // Invert for canyons
        height = height * height;
    }
    else if (this_filter.terrain_type == 5) { // Valleys
        float ridges = terrain_ridged_noise(terrain_pos, this_filter.octaves, this_filter.lacunarity, this_filter.persistence);
        float base = terrain_fbm(terrain_pos * 0.3, this_filter.octaves - 1, this_filter.lacunarity, this_filter.persistence);
        height = mix(1.0 - ridges, base, 0.3);
    }
    
    // Apply erosion
    if (this_filter.erosion_factor > 0.0) {
        height = terrain_apply_erosion(terrain_pos, height, this_filter.erosion_factor);
    }
    
    // Apply height scaling and offset
    height = height * this_filter.terrain_height + this_filter.height_offset;
    
    // Displace Y coordinate
    position.y += height;
    
    // Calculate approximate normal using finite differences for better lighting
    float epsilon = 0.01;
    vec2 h1 = terrain_pos + vec2(epsilon, 0.0);
    vec2 h2 = terrain_pos + vec2(0.0, epsilon);
    
    float height_x = terrain_fbm(h1, this_filter.octaves, this_filter.lacunarity, this_filter.persistence) * this_filter.terrain_height;
    float height_z = terrain_fbm(h2, this_filter.octaves, this_filter.lacunarity, this_filter.persistence) * this_filter.terrain_height;
    
    vec3 tangent_x = normalize(vec3(epsilon, height_x - height, 0.0));
    vec3 tangent_z = normalize(vec3(0.0, height_z - height, epsilon));
    
    normal = normalize(cross(tangent_x, tangent_z));
}