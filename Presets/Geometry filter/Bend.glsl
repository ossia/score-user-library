/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "Bend deformation effect",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Deformation", "Animation" ],
  "INPUTS": [
    {
      "NAME": "bend_amount",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": -5.0,
      "MAX": 5.0
    },
    {
      "NAME": "bend_axis",
      "TYPE": "long",
      "VALUES": ["X", "Y", "Z"],
      "DEFAULT": 1
    },
    {
      "NAME": "bend_direction",
      "TYPE": "long",
      "VALUES": ["X", "Y", "Z"],
      "DEFAULT": 0
    },
    {
      "NAME": "bend_center",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 0.0, 0.0]
    },
    {
      "NAME": "bend_radius",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 10.0
    },
    {
      "NAME": "animate_bend",
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
    vec3 pos = position - this_filter.bend_center;
    
    float bend_factor = this_filter.bend_amount;
    if (this_filter.animate_bend) {
        bend_factor *= sin(TIME * this_filter.animation_speed);
    }
    
    vec3 bent_pos = pos;
    
    // The bend axis is the axis along which the object extends
    // The bend direction is the direction the object bends towards
    
    if (this_filter.bend_axis == 0) { // Bend along X axis
        float x_offset = pos.x;
        float bend_angle = x_offset * bend_factor / this_filter.bend_radius;
        float s = sin(bend_angle);
        float c = cos(bend_angle);
        
        if (this_filter.bend_direction == 1) { // Bend towards Y
            bent_pos.x = this_filter.bend_radius * sin(bend_angle);
            bent_pos.y = pos.y + this_filter.bend_radius * (1.0 - cos(bend_angle));
        } else if (this_filter.bend_direction == 2) { // Bend towards Z
            bent_pos.x = this_filter.bend_radius * sin(bend_angle);
            bent_pos.z = pos.z + this_filter.bend_radius * (1.0 - cos(bend_angle));
        }
        
        // Rotate normal
        if (this_filter.bend_direction == 1) {
            float ny = normal.y * c - normal.x * s;
            float nx = normal.y * s + normal.x * c;
            normal.x = nx;
            normal.y = ny;
        } else if (this_filter.bend_direction == 2) {
            float nz = normal.z * c - normal.x * s;
            float nx = normal.z * s + normal.x * c;
            normal.x = nx;
            normal.z = nz;
        }
    }
    else if (this_filter.bend_axis == 1) { // Bend along Y axis
        float y_offset = pos.y;
        float bend_angle = y_offset * bend_factor / this_filter.bend_radius;
        float s = sin(bend_angle);
        float c = cos(bend_angle);
        
        if (this_filter.bend_direction == 0) { // Bend towards X
            bent_pos.y = this_filter.bend_radius * sin(bend_angle);
            bent_pos.x = pos.x + this_filter.bend_radius * (1.0 - cos(bend_angle));
        } else if (this_filter.bend_direction == 2) { // Bend towards Z
            bent_pos.y = this_filter.bend_radius * sin(bend_angle);
            bent_pos.z = pos.z + this_filter.bend_radius * (1.0 - cos(bend_angle));
        }
        
        // Rotate normal
        if (this_filter.bend_direction == 0) {
            float nx = normal.x * c - normal.y * s;
            float ny = normal.x * s + normal.y * c;
            normal.x = nx;
            normal.y = ny;
        } else if (this_filter.bend_direction == 2) {
            float nz = normal.z * c - normal.y * s;
            float ny = normal.z * s + normal.y * c;
            normal.y = ny;
            normal.z = nz;
        }
    }
    else { // Bend along Z axis
        float z_offset = pos.z;
        float bend_angle = z_offset * bend_factor / this_filter.bend_radius;
        float s = sin(bend_angle);
        float c = cos(bend_angle);
        
        if (this_filter.bend_direction == 0) { // Bend towards X
            bent_pos.z = this_filter.bend_radius * sin(bend_angle);
            bent_pos.x = pos.x + this_filter.bend_radius * (1.0 - cos(bend_angle));
        } else if (this_filter.bend_direction == 1) { // Bend towards Y
            bent_pos.z = this_filter.bend_radius * sin(bend_angle);
            bent_pos.y = pos.y + this_filter.bend_radius * (1.0 - cos(bend_angle));
        }
        
        // Rotate normal
        if (this_filter.bend_direction == 0) {
            float nx = normal.x * c - normal.z * s;
            float nz = normal.x * s + normal.z * c;
            normal.x = nx;
            normal.z = nz;
        } else if (this_filter.bend_direction == 1) {
            float ny = normal.y * c - normal.z * s;
            float nz = normal.y * s + normal.z * c;
            normal.y = ny;
            normal.z = nz;
        }
    }
    
    position = bent_pos + this_filter.bend_center;
}