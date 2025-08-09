/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "Noise-based vertex displacement with multiple noise types",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Noise", "Animation" ],
  "INPUTS": [
    {
      "NAME": "displacement_scale",
      "TYPE": "float",
      "DEFAULT": 0.2,
      "MIN": 0.0,
      "MAX": 2.0
    },
    {
      "NAME": "noise_frequency",
      "TYPE": "float",
      "DEFAULT": 3.0,
      "MIN": 0.1,
      "MAX": 20.0
    },
    {
      "NAME": "noise_type",
      "TYPE": "long",
      "VALUES": ["Value", "Perlin", "Simplex", "Turbulence", "Ridged"],
      "DEFAULT": 1
    },
    {
      "NAME": "displacement_direction",
      "TYPE": "long",
      "VALUES": ["Normal", "World Y", "World XYZ", "Custom"],
      "DEFAULT": 0
    },
    {
      "NAME": "custom_direction",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 1.0, 0.0]
    },
    {
      "NAME": "octaves",
      "TYPE": "long",
      "DEFAULT": 3,
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
      "NAME": "animation_speed",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 5.0
    },
    {
      "NAME": "time_scale",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 2.0
    }
  ]
}*/

// Hash function for noise generation
float noise_hash(vec3 p) {
    p = fract(p * 0.3183099 + 0.1);
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

// Value noise
float noise_value(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    return mix(mix(mix(noise_hash(i + vec3(0.0, 0.0, 0.0)), 
                       noise_hash(i + vec3(1.0, 0.0, 0.0)), f.x),
                   mix(noise_hash(i + vec3(0.0, 1.0, 0.0)), 
                       noise_hash(i + vec3(1.0, 1.0, 0.0)), f.x), f.y),
               mix(mix(noise_hash(i + vec3(0.0, 0.0, 1.0)), 
                       noise_hash(i + vec3(1.0, 0.0, 1.0)), f.x),
                   mix(noise_hash(i + vec3(0.0, 1.0, 1.0)), 
                       noise_hash(i + vec3(1.0, 1.0, 1.0)), f.x), f.y), f.z);
}

// Gradient calculation for Perlin noise
vec3 noise_grad(vec3 p) {
    float h = noise_hash(p);
    vec3 grad = vec3(
        cos(h * 6.28318530718),
        sin(h * 6.28318530718),
        cos(h * 3.14159265359)
    );
    return normalize(grad);
}

// Perlin noise
float noise_perlin(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    
    // Smoothstep for better interpolation
    vec3 u = f * f * (3.0 - 2.0 * f);
    
    return mix(mix(mix(dot(noise_grad(i + vec3(0.0, 0.0, 0.0)), f - vec3(0.0, 0.0, 0.0)),
                       dot(noise_grad(i + vec3(1.0, 0.0, 0.0)), f - vec3(1.0, 0.0, 0.0)), u.x),
                   mix(dot(noise_grad(i + vec3(0.0, 1.0, 0.0)), f - vec3(0.0, 1.0, 0.0)),
                       dot(noise_grad(i + vec3(1.0, 1.0, 0.0)), f - vec3(1.0, 1.0, 0.0)), u.x), u.y),
               mix(mix(dot(noise_grad(i + vec3(0.0, 0.0, 1.0)), f - vec3(0.0, 0.0, 1.0)),
                       dot(noise_grad(i + vec3(1.0, 0.0, 1.0)), f - vec3(1.0, 0.0, 1.0)), u.x),
                   mix(dot(noise_grad(i + vec3(0.0, 1.0, 1.0)), f - vec3(0.0, 1.0, 1.0)),
                       dot(noise_grad(i + vec3(1.0, 1.0, 1.0)), f - vec3(1.0, 1.0, 1.0)), u.x), u.y), u.z);
}

// Simplified Simplex noise (2D projected to 3D)
float noise_simplex(vec3 p) {
    vec2 p2d = p.xy + p.z * 0.1;
    return noise_perlin(vec3(p2d, 0.0));
}

// Fractal noise with octaves
float noise_fractal(vec3 p, int octaves, float lacunarity, float persistence, int noise_type) {
    float value = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    
    for (int i = 0; i < octaves && i < 8; i++) {
        float n = 0.0;
        if (noise_type == 0) n = noise_value(p * frequency);
        else if (noise_type == 1) n = noise_perlin(p * frequency);
        else n = noise_simplex(p * frequency);
        
        value += n * amplitude;
        frequency *= lacunarity;
        amplitude *= persistence;
    }
    
    return value;
}

// Turbulence (absolute value of noise)
float noise_turbulence(vec3 p, int octaves, float lacunarity, float persistence) {
    float value = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    
    for (int i = 0; i < octaves && i < 8; i++) {
        float n = abs(noise_perlin(p * frequency));
        value += n * amplitude;
        frequency *= lacunarity;
        amplitude *= persistence;
    }
    
    return value;
}

// Ridged noise (1 - abs(noise))
float noise_ridged(vec3 p, int octaves, float lacunarity, float persistence) {
    float value = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    
    for (int i = 0; i < octaves && i < 8; i++) {
        float n = 1.0 - abs(noise_perlin(p * frequency));
        n = n * n; // Square for sharper ridges
        value += n * amplitude;
        frequency *= lacunarity;
        amplitude *= persistence;
    }
    
    return value;
}

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    vec3 noise_pos = position * this_filter.noise_frequency + vec3(TIME * this_filter.animation_speed * this_filter.time_scale);
    
    float noise_value = 0.0;
    
    if (this_filter.noise_type == 0) { // Value noise
        noise_value = noise_fractal(noise_pos, this_filter.octaves, this_filter.lacunarity, this_filter.persistence, 0);
    }
    else if (this_filter.noise_type == 1) { // Perlin noise
        noise_value = noise_fractal(noise_pos, this_filter.octaves, this_filter.lacunarity, this_filter.persistence, 1);
    }
    else if (this_filter.noise_type == 2) { // Simplex noise
        noise_value = noise_fractal(noise_pos, this_filter.octaves, this_filter.lacunarity, this_filter.persistence, 2);
    }
    else if (this_filter.noise_type == 3) { // Turbulence
        noise_value = noise_turbulence(noise_pos, this_filter.octaves, this_filter.lacunarity, this_filter.persistence);
    }
    else if (this_filter.noise_type == 4) { // Ridged
        noise_value = noise_ridged(noise_pos, this_filter.octaves, this_filter.lacunarity, this_filter.persistence);
    }
    
    // Scale noise to reasonable range
    noise_value *= this_filter.displacement_scale;
    
    // Apply displacement in chosen direction
    if (this_filter.displacement_direction == 0) { // Along normal
        position += normal * noise_value;
    }
    else if (this_filter.displacement_direction == 1) { // World Y
        position.y += noise_value;
    }
    else if (this_filter.displacement_direction == 2) { // World XYZ
        vec3 noise_3d = vec3(
            noise_fractal(noise_pos + vec3(100.0, 0.0, 0.0), this_filter.octaves, this_filter.lacunarity, this_filter.persistence, this_filter.noise_type),
            noise_fractal(noise_pos + vec3(0.0, 100.0, 0.0), this_filter.octaves, this_filter.lacunarity, this_filter.persistence, this_filter.noise_type),
            noise_fractal(noise_pos + vec3(0.0, 0.0, 100.0), this_filter.octaves, this_filter.lacunarity, this_filter.persistence, this_filter.noise_type)
        );
        position += noise_3d * this_filter.displacement_scale;
    }
    else { // Custom direction
        vec3 custom_dir = normalize(this_filter.custom_direction);
        position += custom_dir * noise_value;
    }
}