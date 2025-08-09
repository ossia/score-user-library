/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "Glitch art and digital corruption effects",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Glitch", "Animation" ],
  "INPUTS": [
    {
      "NAME": "glitch_intensity",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 2.0
    },
    {
      "NAME": "glitch_type",
      "TYPE": "long",
      "VALUES": ["Vertex Jitter", "Scanlines", "Digital Noise", "Data Corruption", "Signal Loss", "Mixed"],
      "DEFAULT": 5
    },
    {
      "NAME": "jitter_frequency",
      "TYPE": "float",
      "DEFAULT": 10.0,
      "MIN": 1.0,
      "MAX": 50.0
    },
    {
      "NAME": "scanline_frequency",
      "TYPE": "float",
      "DEFAULT": 20.0,
      "MIN": 1.0,
      "MAX": 100.0
    },
    {
      "NAME": "corruption_threshold",
      "TYPE": "float",
      "DEFAULT": 0.8,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "time_chaos",
      "TYPE": "float",
      "DEFAULT": 5.0,
      "MIN": 0.1,
      "MAX": 20.0
    },
    {
      "NAME": "glitch_direction",
      "TYPE": "point3D",
      "DEFAULT": [1.0, 0.0, 0.0]
    },
    {
      "NAME": "color_aberration",
      "TYPE": "float",
      "DEFAULT": 0.3,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "signal_loss_amount",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "animation_speed",
      "TYPE": "float",
      "DEFAULT": 3.0,
      "MIN": 0.0,
      "MAX": 10.0
    }
  ]
}*/

// Pseudo-random functions for glitch effects
float glitch_hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

float glitch_hash3d(vec3 p) {
    p = fract(p * 0.3183099 + 0.1);
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float glitch_noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    return mix(mix(mix(glitch_hash3d(i + vec3(0.0, 0.0, 0.0)), 
                       glitch_hash3d(i + vec3(1.0, 0.0, 0.0)), f.x),
                   mix(glitch_hash3d(i + vec3(0.0, 1.0, 0.0)), 
                       glitch_hash3d(i + vec3(1.0, 1.0, 0.0)), f.x), f.y),
               mix(mix(glitch_hash3d(i + vec3(0.0, 0.0, 1.0)), 
                       glitch_hash3d(i + vec3(1.0, 0.0, 1.0)), f.x),
                   mix(glitch_hash3d(i + vec3(0.0, 1.0, 1.0)), 
                       glitch_hash3d(i + vec3(1.0, 1.0, 1.0)), f.x), f.y), f.z);
}

// Digital corruption pattern
float glitch_digital_pattern(vec3 p, float time) {
    float pattern = 0.0;
    
    // Create blocky digital artifacts
    vec3 block_pos = floor(p * 5.0) / 5.0;
    float block_hash = glitch_hash3d(block_pos + floor(time * 10.0));
    
    if (block_hash > this_filter.corruption_threshold) {
        pattern = (block_hash - this_filter.corruption_threshold) / (1.0 - this_filter.corruption_threshold);
        pattern = floor(pattern * 8.0) / 8.0; // Quantize for digital look
    }
    
    return pattern;
}

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    vec3 original_position = position;
    float chaotic_time = TIME * this_filter.animation_speed;
    float vertex_id = float(gl_VertexIndex);
    
    // Create different glitch effects based on type
    vec3 glitch_offset = vec3(0.0);
    
    if (this_filter.glitch_type == 0 || this_filter.glitch_type == 5) { // Vertex Jitter
        // Random jittering of individual vertices
        vec3 jitter_seed = position + vec3(chaotic_time);
        vec3 jitter = vec3(
            glitch_noise(jitter_seed * this_filter.jitter_frequency),
            glitch_noise(jitter_seed * this_filter.jitter_frequency + vec3(100.0, 0.0, 0.0)),
            glitch_noise(jitter_seed * this_filter.jitter_frequency + vec3(0.0, 100.0, 0.0))
        ) - 0.5;
        
        glitch_offset += jitter * this_filter.glitch_intensity * 0.1;
    }
    
    if (this_filter.glitch_type == 1 || this_filter.glitch_type == 5) { // Scanlines
        // Horizontal scanline displacement
        float scanline = floor(position.y * this_filter.scanline_frequency);
        float scanline_hash = glitch_hash(scanline + floor(chaotic_time * 20.0));
        
        if (scanline_hash > 0.7) {
            vec3 direction = normalize(this_filter.glitch_direction);
            float displacement = (scanline_hash - 0.7) / 0.3;
            displacement = floor(displacement * 8.0) / 8.0; // Quantize
            glitch_offset += direction * displacement * this_filter.glitch_intensity * 0.2;
        }
    }
    
    if (this_filter.glitch_type == 2 || this_filter.glitch_type == 5) { // Digital Noise
        // High-frequency digital noise
        float noise_pattern = glitch_digital_pattern(position, chaotic_time);
        vec3 noise_direction = normalize(vec3(
            glitch_hash(vertex_id + chaotic_time),
            glitch_hash(vertex_id + chaotic_time + 100.0),
            glitch_hash(vertex_id + chaotic_time + 200.0)
        ) - 0.5);
        
        glitch_offset += noise_direction * noise_pattern * this_filter.glitch_intensity * 0.15;
    }
    
    if (this_filter.glitch_type == 3 || this_filter.glitch_type == 5) { // Data Corruption
        // Simulate corrupted vertex data
        float corruption = glitch_hash3d(position + floor(chaotic_time * 5.0));
        
        if (corruption > this_filter.corruption_threshold) {
            // "Corrupt" the position data
            vec3 corrupted_pos = position;
            corrupted_pos.x = floor(corrupted_pos.x * 8.0) / 8.0;
            corrupted_pos.y = floor(corrupted_pos.y * 8.0) / 8.0;
            corrupted_pos.z = floor(corrupted_pos.z * 8.0) / 8.0;
            
            float corrupt_amount = (corruption - this_filter.corruption_threshold) / (1.0 - this_filter.corruption_threshold);
            glitch_offset += (corrupted_pos - position) * corrupt_amount * this_filter.glitch_intensity;
        }
    }
    
    if (this_filter.glitch_type == 4 || this_filter.glitch_type == 5) { // Signal Loss
        // Simulate signal loss/dropout
        float signal_noise = glitch_noise(position * 2.0 + vec3(chaotic_time * this_filter.time_chaos));
        
        if (signal_noise < this_filter.signal_loss_amount) {
            // Move vertices toward origin (signal dropout)
            glitch_offset += -position * (this_filter.signal_loss_amount - signal_noise) * this_filter.glitch_intensity * 0.3;
            
            // Also corrupt the vertex completely in extreme cases
            if (signal_noise < this_filter.signal_loss_amount * 0.3) {
                glitch_offset += vec3(
                    glitch_hash(vertex_id + floor(chaotic_time * 30.0)),
                    glitch_hash(vertex_id + floor(chaotic_time * 30.0) + 1000.0),
                    glitch_hash(vertex_id + floor(chaotic_time * 30.0) + 2000.0)
                ) * this_filter.glitch_intensity * 0.5;
            }
        }
    }
    
    // Apply glitch displacement
    position += glitch_offset;
    
    // Color corruption/aberration effects
    if (this_filter.color_aberration > 0.0) {
        vec3 aberration = vec3(
            glitch_hash(vertex_id + floor(chaotic_time * 15.0)),
            glitch_hash(vertex_id + floor(chaotic_time * 15.0) + 500.0),
            glitch_hash(vertex_id + floor(chaotic_time * 15.0) + 1500.0)
        );
        
        // Apply random color shifts
        color.rgb = mix(color.rgb, aberration, this_filter.color_aberration * this_filter.glitch_intensity * 0.3);
        
        // Occasionally make colors completely digital/quantized
        if (glitch_hash3d(position + vec3(chaotic_time)) > 0.9) {
            color.rgb = floor(color.rgb * 4.0) / 4.0;
        }
    }
    
    // Corrupt alpha channel occasionally
    float alpha_corruption = glitch_hash(vertex_id + floor(chaotic_time * 8.0));
    if (alpha_corruption > 0.95) {
        color.a = floor(color.a * 3.0) / 3.0;
    }
}