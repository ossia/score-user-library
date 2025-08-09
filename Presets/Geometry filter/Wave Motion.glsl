/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "Wave motion and ripple effects",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Wave", "Animation" ],
  "INPUTS": [
    {
      "NAME": "wave_amplitude",
      "TYPE": "float",
      "DEFAULT": 0.1,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "wave_frequency",
      "TYPE": "float",
      "DEFAULT": 5.0,
      "MIN": 0.0,
      "MAX": 20.0
    },
    {
      "NAME": "wave_speed",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 10.0
    },
    {
      "NAME": "wave_direction",
      "TYPE": "point2D",
      "DEFAULT": [1.0, 0.0]
    },
    {
      "NAME": "secondary_amplitude",
      "TYPE": "float",
      "DEFAULT": 0.05,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "secondary_frequency",
      "TYPE": "float",
      "DEFAULT": 8.0,
      "MIN": 0.0,
      "MAX": 20.0
    },
    {
      "NAME": "secondary_speed",
      "TYPE": "float",
      "DEFAULT": 1.5,
      "MIN": 0.0,
      "MAX": 10.0
    },
    {
      "NAME": "wave_type",
      "TYPE": "long",
      "VALUES": ["Simple", "Radial", "Interference"],
      "DEFAULT": 0
    }
  ]
}*/

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    vec2 wave_dir = normalize(this_filter.wave_direction);
    
    if (this_filter.wave_type == 0) {
        // Simple directional wave
        float wave_phase = dot(position.xz, wave_dir) * this_filter.wave_frequency + TIME * this_filter.wave_speed;
        float displacement = sin(wave_phase) * this_filter.wave_amplitude;
        position.y += displacement;
    }
    else if (this_filter.wave_type == 1) {
        // Radial wave (ripples from center)
        float distance = length(position.xz);
        float wave_phase = distance * this_filter.wave_frequency - TIME * this_filter.wave_speed;
        float displacement = sin(wave_phase) * this_filter.wave_amplitude;
        // Attenuate with distance for more realistic ripples
        displacement *= exp(-distance * 0.1);
        position.y += displacement;
    }
    else if (this_filter.wave_type == 2) {
        // Interference pattern (two waves)
        // Primary wave
        float wave1_phase = dot(position.xz, wave_dir) * this_filter.wave_frequency + TIME * this_filter.wave_speed;
        float displacement1 = sin(wave1_phase) * this_filter.wave_amplitude;
        
        // Secondary wave (perpendicular direction)
        vec2 wave_dir2 = vec2(-wave_dir.y, wave_dir.x);
        float wave2_phase = dot(position.xz, wave_dir2) * this_filter.secondary_frequency + TIME * this_filter.secondary_speed;
        float displacement2 = sin(wave2_phase) * this_filter.secondary_amplitude;
        
        position.y += displacement1 + displacement2;
    }
}