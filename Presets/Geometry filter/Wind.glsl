/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "Wind simulation effects for vegetation and flexible objects",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Wind", "Animation" ],
  "INPUTS": [
    {
      "NAME": "wind_strength",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 5.0
    },
    {
      "NAME": "wind_direction",
      "TYPE": "point3D",
      "DEFAULT": [1.0, 0.0, 0.5]
    },
    {
      "NAME": "wind_speed",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 0.0,
      "MAX": 10.0
    },
    {
      "NAME": "primary_sway_frequency",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 5.0
    },
    {
      "NAME": "secondary_flutter_frequency",
      "TYPE": "float",
      "DEFAULT": 8.0,
      "MIN": 1.0,
      "MAX": 20.0
    },
    {
      "NAME": "flutter_amount",
      "TYPE": "float",
      "DEFAULT": 0.3,
      "MIN": 0.0,
      "MAX": 2.0
    },
    {
      "NAME": "flexibility_mask",
      "TYPE": "long",
      "VALUES": ["Vertex Color R", "Vertex Color G", "Height", "Distance", "Manual"],
      "DEFAULT": 2
    },
    {
      "NAME": "flexibility_power",
      "TYPE": "float",
      "DEFAULT": 2.0,
      "MIN": 0.5,
      "MAX": 4.0
    },
    {
      "NAME": "wind_randomness",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 2.0
    },
    {
      "NAME": "base_position",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 0.0, 0.0]
    }
  ]
}*/

// Wind noise function
float wind_hash(vec3 p) {
    p = fract(p * 0.3183099 + 0.1);
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float wind_noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    return mix(mix(mix(wind_hash(i + vec3(0.0, 0.0, 0.0)), 
                       wind_hash(i + vec3(1.0, 0.0, 0.0)), f.x),
                   mix(wind_hash(i + vec3(0.0, 1.0, 0.0)), 
                       wind_hash(i + vec3(1.0, 1.0, 0.0)), f.x), f.y),
               mix(mix(wind_hash(i + vec3(0.0, 0.0, 1.0)), 
                       wind_hash(i + vec3(1.0, 0.0, 1.0)), f.x),
                   mix(wind_hash(i + vec3(0.0, 1.0, 1.0)), 
                       wind_hash(i + vec3(1.0, 1.0, 1.0)), f.x), f.y), f.z);
}

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    vec3 wind_dir = normalize(this_filter.wind_direction);
    vec3 relative_pos = position - this_filter.base_position;
    
    // Calculate flexibility factor based on chosen mask
    float flexibility = 1.0;
    
    if (this_filter.flexibility_mask == 0) { // Vertex Color R
        flexibility = color.r;
    }
    else if (this_filter.flexibility_mask == 1) { // Vertex Color G
        flexibility = color.g;
    }
    else if (this_filter.flexibility_mask == 2) { // Height
        float max_height = 2.0; // Assume max object height
        flexibility = clamp((relative_pos.y + max_height) / (2.0 * max_height), 0.0, 1.0);
    }
    else if (this_filter.flexibility_mask == 3) { // Distance from base
        float max_distance = 2.0; // Assume max distance
        flexibility = clamp(length(relative_pos) / max_distance, 0.0, 1.0);
    }
    // If manual (4), flexibility stays 1.0
    
    // Apply power curve to flexibility for more natural falloff
    flexibility = pow(flexibility, this_filter.flexibility_power);
    
    // Primary sway - low frequency, large amplitude movement
    float sway_phase = position.x * 0.5 + position.z * 0.3 + TIME * this_filter.wind_speed * this_filter.primary_sway_frequency;
    float primary_sway = sin(sway_phase) * this_filter.wind_strength * 0.2;
    
    // Add some variation to the sway based on position
    float sway_variation = wind_noise(position * 0.1 + vec3(TIME * 0.1)) * 0.5 + 0.5;
    primary_sway *= sway_variation;
    
    // Secondary flutter - high frequency, small amplitude movement
    vec3 flutter_pos = position * this_filter.secondary_flutter_frequency + vec3(TIME * this_filter.wind_speed * 3.0);
    vec3 flutter_noise = vec3(
        wind_noise(flutter_pos),
        wind_noise(flutter_pos + vec3(100.0, 0.0, 0.0)),
        wind_noise(flutter_pos + vec3(0.0, 100.0, 0.0))
    ) - 0.5;
    
    vec3 secondary_flutter = flutter_noise * this_filter.flutter_amount * this_filter.wind_strength * 0.1;
    
    // Random wind gusts
    float gust_phase = TIME * this_filter.wind_speed * 0.3 + position.x * 0.1;
    float gust_strength = (sin(gust_phase) + 1.0) * 0.5;
    gust_strength = pow(gust_strength, 3.0); // Make gusts more intermittent
    
    vec3 gust_direction = wind_dir + vec3(
        wind_noise(position * 0.05 + vec3(TIME * 0.2)) - 0.5,
        0.0,
        wind_noise(position * 0.05 + vec3(TIME * 0.2, 100.0, 0.0)) - 0.5
    ) * this_filter.wind_randomness;
    gust_direction = normalize(gust_direction);
    
    vec3 gust_offset = gust_direction * gust_strength * this_filter.wind_strength * 0.15;
    
    // Combine all wind effects
    vec3 primary_offset = wind_dir * primary_sway;
    vec3 total_wind = primary_offset + secondary_flutter + gust_offset;
    
    // Apply flexibility mask
    total_wind *= flexibility;
    
    // Apply wind displacement
    position += total_wind;
    
    // Bend the normal slightly to match the wind direction for more realistic lighting
    vec3 wind_influence = normalize(total_wind + vec3(0.001)); // Avoid zero vector
    normal = normalize(normal + wind_influence * flexibility * 0.3);
}