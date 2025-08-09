/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "Morphing and volumetric transition effects",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Transition", "Animation" ],
  "INPUTS": [
    {
      "NAME": "morph_progress",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "morph_type",
      "TYPE": "long",
      "VALUES": ["Sphere", "Box", "Point", "Genie", "Dissolve"],
      "DEFAULT": 0
    },
    {
      "NAME": "target_position",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 0.0, 0.0]
    },
    {
      "NAME": "target_scale",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.0,
      "MAX": 2.0
    },
    {
      "NAME": "morph_curve",
      "TYPE": "long",
      "VALUES": ["Linear", "Ease In", "Ease Out", "Ease In-Out", "Bounce"],
      "DEFAULT": 3
    },
    {
      "NAME": "animate_morph",
      "TYPE": "bool",
      "DEFAULT": true
    },
    {
      "NAME": "animation_speed",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 2.0
    },
    {
      "NAME": "noise_amount",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.0,
      "MAX": 1.0
    }
  ]
}*/

// Simple hash function for pseudo-random values
float morph_hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

float morph_noise3D(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float n = i.x + i.y * 57.0 + 113.0 * i.z;
    
    return mix(mix(mix(morph_hash(n + 0.0), morph_hash(n + 1.0), f.x),
                   mix(morph_hash(n + 57.0), morph_hash(n + 58.0), f.x), f.y),
               mix(mix(morph_hash(n + 113.0), morph_hash(n + 114.0), f.x),
                   mix(morph_hash(n + 170.0), morph_hash(n + 171.0), f.x), f.y), f.z);
}

float morph_easing(float t, int curve_type) {
    if (curve_type == 0) { // Linear
        return t;
    }
    else if (curve_type == 1) { // Ease In
        return t * t * t;
    }
    else if (curve_type == 2) { // Ease Out
        float p = 1.0 - t;
        return 1.0 - p * p * p;
    }
    else if (curve_type == 3) { // Ease In-Out
        if (t < 0.5) {
            return 4.0 * t * t * t;
        } else {
            float p = 2.0 * t - 2.0;
            return 1.0 + p * p * p * 0.5;
        }
    }
    else { // Bounce
        if (t < 0.5) {
            return 8.0 * t * t * t * t;
        } else {
            float p = t - 1.0;
            return 1.0 + 8.0 * p * p * p * p;
        }
    }
}

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    float progress = this_filter.morph_progress;
    if (this_filter.animate_morph) {
        progress = (sin(TIME * this_filter.animation_speed) + 1.0) * 0.5;
    }
    
    progress = morph_easing(progress, this_filter.morph_curve);
    
    vec3 original_pos = position;
    vec3 target_pos = this_filter.target_position;
    
    if (this_filter.morph_type == 0) { // Sphere morph
        vec3 dir = normalize(position - this_filter.target_position);
        vec3 sphere_pos = this_filter.target_position + dir * this_filter.target_scale;
        position = mix(original_pos, sphere_pos, progress);
    }
    else if (this_filter.morph_type == 1) { // Box morph
        vec3 relative_pos = position - this_filter.target_position;
        vec3 box_pos = this_filter.target_position + 
                      clamp(relative_pos, -vec3(this_filter.target_scale), vec3(this_filter.target_scale));
        position = mix(original_pos, box_pos, progress);
    }
    else if (this_filter.morph_type == 2) { // Point collapse
        position = mix(original_pos, target_pos, progress);
    }
    else if (this_filter.morph_type == 3) { // Genie effect
        vec3 relative_pos = position - this_filter.target_position;
        
        // Height-based interpolation factor
        float height = relative_pos.y;
        float max_height = 2.0; // Assume object height
        float height_factor = clamp((height + max_height) / (2.0 * max_height), 0.0, 1.0);
        
        // The bottom collapses faster than the top
        float local_progress = progress * (2.0 - height_factor);
        local_progress = clamp(local_progress, 0.0, 1.0);
        
        // Collapse X and Z based on height
        vec3 genie_pos = position;
        genie_pos.x = mix(position.x, target_pos.x, local_progress);
        genie_pos.z = mix(position.z, target_pos.z, local_progress);
        
        // Also collapse Y, but more gradually
        genie_pos.y = mix(position.y, target_pos.y, progress * height_factor);
        
        position = genie_pos;
    }
    else if (this_filter.morph_type == 4) { // Dissolve effect
        float noise = morph_noise3D(original_pos * 5.0 + vec3(TIME * 0.1));
        float dissolve_threshold = 1.0 - progress + noise * this_filter.noise_amount;
        
        if (dissolve_threshold > 0.5) {
            // Particle is still visible, add some displacement
            vec3 noise_offset = vec3(
                morph_noise3D(original_pos * 3.0 + vec3(TIME * 0.2)),
                morph_noise3D(original_pos * 3.0 + vec3(TIME * 0.2, 0.0, 100.0)),
                morph_noise3D(original_pos * 3.0 + vec3(TIME * 0.2, 100.0, 0.0))
            ) - 0.5;
            
            position += noise_offset * progress * this_filter.noise_amount;
        } else {
            // Move towards target with noise
            position = mix(original_pos, target_pos, (0.5 - dissolve_threshold) * 2.0);
        }
        
        // Fade out color
        color.a *= dissolve_threshold;
    }
    
    // Add noise to all morph types except dissolve (which has its own noise)
    if (this_filter.morph_type != 4 && this_filter.noise_amount > 0.0) {
        vec3 noise_offset = vec3(
            morph_noise3D(original_pos * 10.0 + vec3(TIME)),
            morph_noise3D(original_pos * 10.0 + vec3(TIME, 0.0, 100.0)),
            morph_noise3D(original_pos * 10.0 + vec3(TIME, 100.0, 0.0))
        ) - 0.5;
        
        position += noise_offset * this_filter.noise_amount * progress;
    }
}