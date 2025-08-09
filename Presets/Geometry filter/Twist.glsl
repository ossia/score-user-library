/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "Twist deformation effect",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Deformation", "Animation" ],
  "INPUTS": [
    {
      "NAME": "twist_amount",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": -10.0,
      "MAX": 10.0
    },
    {
      "NAME": "twist_axis",
      "TYPE": "long",
      "VALUES": ["X", "Y", "Z"],
      "DEFAULT": 1
    },
    {
      "NAME": "twist_center",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 0.0, 0.0]
    },
    {
      "NAME": "twist_falloff",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.01,
      "MAX": 10.0
    },
    {
      "NAME": "animate_twist",
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
    vec3 pos = position - this_filter.twist_center;
    
    float twist_angle = this_filter.twist_amount;
    if (this_filter.animate_twist) {
        twist_angle *= sin(TIME * this_filter.animation_speed);
    }
    
    float angle = 0.0;
    vec3 rotated_pos = pos;
    
    if (this_filter.twist_axis == 0) { // X axis
        float t = (pos.x + this_filter.twist_falloff) / (2.0 * this_filter.twist_falloff);
        t = clamp(t, 0.0, 1.0);
        angle = twist_angle * t;
        
        float s = sin(angle);
        float c = cos(angle);
        rotated_pos.y = pos.y * c - pos.z * s;
        rotated_pos.z = pos.y * s + pos.z * c;
    }
    else if (this_filter.twist_axis == 1) { // Y axis
        float t = (pos.y + this_filter.twist_falloff) / (2.0 * this_filter.twist_falloff);
        t = clamp(t, 0.0, 1.0);
        angle = twist_angle * t;
        
        float s = sin(angle);
        float c = cos(angle);
        rotated_pos.x = pos.x * c - pos.z * s;
        rotated_pos.z = pos.x * s + pos.z * c;
    }
    else { // Z axis
        float t = (pos.z + this_filter.twist_falloff) / (2.0 * this_filter.twist_falloff);
        t = clamp(t, 0.0, 1.0);
        angle = twist_angle * t;
        
        float s = sin(angle);
        float c = cos(angle);
        rotated_pos.x = pos.x * c - pos.y * s;
        rotated_pos.y = pos.x * s + pos.y * c;
    }
    
    position = rotated_pos + this_filter.twist_center;
    
    // Also rotate the normal and tangent
    if (this_filter.twist_axis == 0) {
        float s = sin(angle);
        float c = cos(angle);
        float ny = normal.y * c - normal.z * s;
        float nz = normal.y * s + normal.z * c;
        normal.y = ny;
        normal.z = nz;
        
        float ty = tangent.y * c - tangent.z * s;
        float tz = tangent.y * s + tangent.z * c;
        tangent.y = ty;
        tangent.z = tz;
    }
    else if (this_filter.twist_axis == 1) {
        float s = sin(angle);
        float c = cos(angle);
        float nx = normal.x * c - normal.z * s;
        float nz = normal.x * s + normal.z * c;
        normal.x = nx;
        normal.z = nz;
        
        float tx = tangent.x * c - tangent.z * s;
        float tz = tangent.x * s + tangent.z * c;
        tangent.x = tx;
        tangent.z = tz;
    }
    else {
        float s = sin(angle);
        float c = cos(angle);
        float nx = normal.x * c - normal.y * s;
        float ny = normal.x * s + normal.y * c;
        normal.x = nx;
        normal.y = ny;
        
        float tx = tangent.x * c - tangent.y * s;
        float ty = tangent.x * s + tangent.y * c;
        tangent.x = tx;
        tangent.y = ty;
    }
}