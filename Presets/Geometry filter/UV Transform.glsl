/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "UV coordinate manipulation and transformation effects",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "UV", "Animation" ],
  "INPUTS": [
    {
      "NAME": "scroll_u",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": -10.0,
      "MAX": 10.0
    },
    {
      "NAME": "scroll_v",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": -10.0,
      "MAX": 10.0
    },
    {
      "NAME": "scroll_speed_u",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": -5.0,
      "MAX": 5.0
    },
    {
      "NAME": "scroll_speed_v",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": -5.0,
      "MAX": 5.0
    },
    {
      "NAME": "rotation_angle",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": -6.28,
      "MAX": 6.28
    },
    {
      "NAME": "rotation_speed",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": -5.0,
      "MAX": 5.0
    },
    {
      "NAME": "scale_u",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.01,
      "MAX": 10.0
    },
    {
      "NAME": "scale_v",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.01,
      "MAX": 10.0
    },
    {
      "NAME": "pivot_u",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "pivot_v",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "distortion_type",
      "TYPE": "long",
      "VALUES": ["None", "Wave", "Noise", "Polar", "Fisheye"],
      "DEFAULT": 0
    },
    {
      "NAME": "distortion_amount",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "distortion_frequency",
      "TYPE": "float",
      "DEFAULT": 5.0,
      "MIN": 0.1,
      "MAX": 20.0
    }
  ]
}*/

// UV noise function
float uv_hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453123);
}

float uv_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = uv_hash(i);
    float b = uv_hash(i + vec2(1.0, 0.0));
    float c = uv_hash(i + vec2(0.0, 1.0));
    float d = uv_hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

vec2 uv_rotate(vec2 uv, float angle, vec2 pivot) {
    uv -= pivot;
    float s = sin(angle);
    float c = cos(angle);
    mat2 rotation_matrix = mat2(c, -s, s, c);
    uv = rotation_matrix * uv;
    uv += pivot;
    return uv;
}

vec2 uv_apply_distortion(vec2 uv, int distortion_type, float amount, float frequency) {
    vec2 distorted_uv = uv;
    
    if (distortion_type == 1) { // Wave
        distorted_uv.x += sin(uv.y * frequency + TIME) * amount;
        distorted_uv.y += cos(uv.x * frequency + TIME * 1.3) * amount;
    }
    else if (distortion_type == 2) { // Noise
        vec2 noise_offset = vec2(
            uv_noise(uv * frequency + vec2(TIME * 0.5)),
            uv_noise(uv * frequency + vec2(TIME * 0.5, 100.0))
        ) - 0.5;
        distorted_uv += noise_offset * amount;
    }
    else if (distortion_type == 3) { // Polar distortion
        vec2 center = vec2(0.5, 0.5);
        vec2 relative = uv - center;
        float radius = length(relative);
        float angle = atan(relative.y, relative.x);
        
        // Apply distortion to radius and angle
        radius += sin(angle * frequency + TIME) * amount * 0.1;
        angle += sin(radius * frequency + TIME) * amount;
        
        distorted_uv = center + vec2(cos(angle), sin(angle)) * radius;
    }
    else if (distortion_type == 4) { // Fisheye
        vec2 center = vec2(0.5, 0.5);
        vec2 relative = uv - center;
        float radius = length(relative);
        
        // Apply fisheye distortion
        float distorted_radius = radius * (1.0 + amount * radius * radius);
        distorted_uv = center + normalize(relative) * distorted_radius;
    }
    
    return distorted_uv;
}

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    vec2 modified_uv = uv;
    vec2 pivot = vec2(this_filter.pivot_u, this_filter.pivot_v);
    
    // Apply scaling first (around pivot)
    modified_uv -= pivot;
    modified_uv.x *= this_filter.scale_u;
    modified_uv.y *= this_filter.scale_v;
    modified_uv += pivot;
    
    // Apply rotation (around pivot)
    float rotation = this_filter.rotation_angle + TIME * this_filter.rotation_speed;
    if (abs(rotation) > 0.001) {
        modified_uv = uv_rotate(modified_uv, rotation, pivot);
    }
    
    // Apply scrolling
    vec2 scroll_offset = vec2(
        this_filter.scroll_u + TIME * this_filter.scroll_speed_u,
        this_filter.scroll_v + TIME * this_filter.scroll_speed_v
    );
    modified_uv += scroll_offset;
    
    // Apply distortion
    if (this_filter.distortion_type > 0) {
        modified_uv = uv_apply_distortion(modified_uv, this_filter.distortion_type, 
                                         this_filter.distortion_amount, this_filter.distortion_frequency);
    }
    
    // Update the UV coordinates
    uv = modified_uv;
}