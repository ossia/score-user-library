/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "Taper deformation effect",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Deformation", "Animation" ],
  "INPUTS": [
    {
      "NAME": "taper_amount",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 2.0
    },
    {
      "NAME": "taper_axis",
      "TYPE": "long",
      "VALUES": ["X", "Y", "Z"],
      "DEFAULT": 1
    },
    {
      "NAME": "taper_center",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 0.0, 0.0]
    },
    {
      "NAME": "taper_range",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 10.0
    },
    {
      "NAME": "taper_curve",
      "TYPE": "long",
      "VALUES": ["Linear", "Quadratic", "Exponential", "Sine"],
      "DEFAULT": 0
    },
    {
      "NAME": "animate_taper",
      "TYPE": "bool",
      "DEFAULT": true
    },
    {
      "NAME": "animation_speed",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 5.0
    }
  ]
}*/

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    vec3 pos = position - this_filter.taper_center;
    
    float taper = this_filter.taper_amount;
    if (this_filter.animate_taper) {
        taper = mix(0.1, this_filter.taper_amount, (sin(TIME * this_filter.animation_speed) + 1.0) * 0.5);
    }
    
    float t = 0.0;
    vec3 tapered_pos = pos;
    
    // Calculate normalized position along taper axis
    if (this_filter.taper_axis == 0) { // X axis
        t = (pos.x + this_filter.taper_range) / (2.0 * this_filter.taper_range);
    }
    else if (this_filter.taper_axis == 1) { // Y axis
        t = (pos.y + this_filter.taper_range) / (2.0 * this_filter.taper_range);
    }
    else { // Z axis
        t = (pos.z + this_filter.taper_range) / (2.0 * this_filter.taper_range);
    }
    
    t = clamp(t, 0.0, 1.0);
    
    // Apply taper curve
    float scale = 1.0;
    if (this_filter.taper_curve == 0) { // Linear
        scale = mix(1.0, taper, t);
    }
    else if (this_filter.taper_curve == 1) { // Quadratic
        scale = mix(1.0, taper, t * t);
    }
    else if (this_filter.taper_curve == 2) { // Exponential
        scale = mix(1.0, taper, 1.0 - exp(-3.0 * t));
    }
    else { // Sine
        scale = mix(1.0, taper, sin(t * 3.14159265 * 0.5));
    }
    
    // Apply scaling perpendicular to taper axis
    if (this_filter.taper_axis == 0) { // X axis
        tapered_pos.y *= scale;
        tapered_pos.z *= scale;
    }
    else if (this_filter.taper_axis == 1) { // Y axis
        tapered_pos.x *= scale;
        tapered_pos.z *= scale;
    }
    else { // Z axis
        tapered_pos.x *= scale;
        tapered_pos.y *= scale;
    }
    
    position = tapered_pos + this_filter.taper_center;
}