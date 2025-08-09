/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "Procedural vertex coloration effects",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Color", "Animation" ],
  "INPUTS": [
    {
      "NAME": "color_mode",
      "TYPE": "long",
      "VALUES": ["Height Gradient", "Distance Gradient", "Normal Based", "Position Based", "Iridescent", "Noise", "Vertex Index"],
      "DEFAULT": 0
    },
    {
      "NAME": "color_a",
      "TYPE": "color",
      "DEFAULT": [1.0, 0.0, 0.0, 1.0]
    },
    {
      "NAME": "color_b",
      "TYPE": "color",
      "DEFAULT": [0.0, 0.0, 1.0, 1.0]
    },
    {
      "NAME": "gradient_center",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 0.0, 0.0]
    },
    {
      "NAME": "gradient_range",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 0.1,
      "MAX": 10.0
    },
    {
      "NAME": "animation_speed",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 5.0
    },
    {
      "NAME": "color_frequency",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 10.0
    },
    {
      "NAME": "noise_scale",
      "TYPE": "float",
      "DEFAULT": 5.0,
      "MIN": 0.1,
      "MAX": 20.0
    },
    {
      "NAME": "iridescence_strength",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 2.0
    },
    {
      "NAME": "use_original_color",
      "TYPE": "bool",
      "DEFAULT": false
    },
    {
      "NAME": "blend_factor",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 1.0
    }
  ]
}*/

// Color utility functions
vec3 color_hsv_to_rgb(vec3 hsv) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
    return hsv.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y);
}

float color_hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

float color_hash3d(vec3 p) {
    p = fract(p * 0.3183099 + 0.1);
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float color_noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    return mix(mix(mix(color_hash3d(i + vec3(0.0, 0.0, 0.0)), 
                       color_hash3d(i + vec3(1.0, 0.0, 0.0)), f.x),
                   mix(color_hash3d(i + vec3(0.0, 1.0, 0.0)), 
                       color_hash3d(i + vec3(1.0, 1.0, 0.0)), f.x), f.y),
               mix(mix(color_hash3d(i + vec3(0.0, 0.0, 1.0)), 
                       color_hash3d(i + vec3(1.0, 0.0, 1.0)), f.x),
                   mix(color_hash3d(i + vec3(0.0, 1.0, 1.0)), 
                       color_hash3d(i + vec3(1.0, 1.0, 1.0)), f.x), f.y), f.z);
}

// Iridescent color palette based on cosine functions
vec3 color_cosine_palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(6.28318 * (c * t + d));
}

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    vec4 original_color = color;
    vec3 new_color = vec3(1.0);
    float t = 0.0;
    
    if (this_filter.color_mode == 0) { // Height Gradient
        t = (position.y - this_filter.gradient_center.y + this_filter.gradient_range) / (2.0 * this_filter.gradient_range);
        t = clamp(t, 0.0, 1.0);
        new_color = mix(this_filter.color_a.rgb, this_filter.color_b.rgb, t);
    }
    else if (this_filter.color_mode == 1) { // Distance Gradient  
        float distance = length(position - this_filter.gradient_center);
        t = clamp(distance / this_filter.gradient_range, 0.0, 1.0);
        new_color = mix(this_filter.color_a.rgb, this_filter.color_b.rgb, t);
    }
    else if (this_filter.color_mode == 2) { // Normal Based
        // Use the normal to determine color - more dramatic lighting-like effect
        vec3 abs_normal = abs(normal);
        new_color = this_filter.color_a.rgb * abs_normal.x + 
                   this_filter.color_b.rgb * abs_normal.y + 
                   vec3(0.5, 1.0, 0.5) * abs_normal.z; // Green tint for Z
    }
    else if (this_filter.color_mode == 3) { // Position Based
        // Map XYZ position to RGB
        vec3 pos_normalized = (position - this_filter.gradient_center) / this_filter.gradient_range;
        pos_normalized = pos_normalized * 0.5 + 0.5; // Map to 0-1 range
        new_color = clamp(pos_normalized, 0.0, 1.0);
    }
    else if (this_filter.color_mode == 4) { // Iridescent
        // View-dependent iridescent coloring
        vec3 view_dir = normalize(vec3(0.0, 0.0, 1.0)); // Simplified view direction
        float fresnel = 1.0 - abs(dot(normal, view_dir));
        fresnel = pow(fresnel, 2.0);
        
        float iridescence = fresnel + sin(position.x * this_filter.color_frequency + TIME * this_filter.animation_speed) * 0.5;
        iridescence += cos(position.y * this_filter.color_frequency * 1.3 + TIME * this_filter.animation_speed * 0.7) * 0.3;
        iridescence = fract(iridescence);
        
        // Create iridescent color using cosine palette
        new_color = color_cosine_palette(
            iridescence * this_filter.iridescence_strength,
            vec3(0.5, 0.5, 0.5),    // offset
            vec3(0.5, 0.5, 0.5),    // amplitude  
            vec3(1.0, 1.0, 1.0),    // frequency
            vec3(0.0, 0.33, 0.67)   // phase
        );
    }
    else if (this_filter.color_mode == 5) { // Noise
        float noise_value = color_noise(position * this_filter.noise_scale + vec3(TIME * this_filter.animation_speed));
        new_color = mix(this_filter.color_a.rgb, this_filter.color_b.rgb, noise_value);
    }
    else if (this_filter.color_mode == 6) { // Vertex Index
        // Use gl_VertexIndex to create unique colors per vertex
        float index_hash = color_hash(float(gl_VertexIndex));
        
        // Create HSV color from hash
        vec3 hsv_color = vec3(
            index_hash, // Hue
            0.7 + 0.3 * sin(TIME * this_filter.animation_speed + index_hash * 6.28), // Saturation
            0.8 + 0.2 * cos(TIME * this_filter.animation_speed * 1.3 + index_hash * 3.14) // Value
        );
        
        new_color = color_hsv_to_rgb(hsv_color);
    }
    
    // Blend with original color if requested
    if (this_filter.use_original_color) {
        new_color = mix(original_color.rgb, new_color, this_filter.blend_factor);
    }
    
    // Apply the new color
    color.rgb = new_color;
    
    // Preserve alpha unless it was part of the original gradient colors
    if (!this_filter.use_original_color) {
        if (this_filter.color_mode == 0 || this_filter.color_mode == 1) {
            color.a = mix(this_filter.color_a.a, this_filter.color_b.a, t);
        }
    }
}