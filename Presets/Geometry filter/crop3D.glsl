/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "3D bounding box cropping with transform operations",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "Cropping", "Transform" ],
  "INPUTS": [
    {
      "NAME": "box_min",
      "TYPE": "point3D",
      "DEFAULT": [-1.0, -1.0, -1.0]
    },
    {
      "NAME": "box_max",
      "TYPE": "point3D",
      "DEFAULT": [1.0, 1.0, 1.0]
    },
    {
      "NAME": "box_position",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 0.0, 0.0]
    },
    {
      "NAME": "box_rotation",
      "TYPE": "point3D",
      "DEFAULT": [0.0, 0.0, 0.0]
    },
    {
      "NAME": "box_scale",
      "TYPE": "point3D",
      "DEFAULT": [1.0, 1.0, 1.0]
    },
    {
      "NAME": "crop_mode",
      "TYPE": "long",
      "VALUES": ["Inside", "Outside"],
      "DEFAULT": 0
    },
    {
      "NAME": "falloff_distance",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": 0.0,
      "MAX": 1.0
    },
    {
      "NAME": "falloff_type",
      "TYPE": "long",
      "VALUES": ["Linear", "Smooth"],
      "DEFAULT": 1
    }
  ]
}*/

mat3 rotation_matrix(vec3 angles)
{
    vec3 rad = radians(angles);
    float cx = cos(rad.x), sx = sin(rad.x);
    float cy = cos(rad.y), sy = sin(rad.y);
    float cz = cos(rad.z), sz = sin(rad.z);
    
    mat3 rx = mat3(
        1.0, 0.0, 0.0,
        0.0, cx, -sx,
        0.0, sx, cx
    );
    
    mat3 ry = mat3(
        cy, 0.0, sy,
        0.0, 1.0, 0.0,
        -sy, 0.0, cy
    );
    
    mat3 rz = mat3(
        cz, -sz, 0.0,
        sz, cz, 0.0,
        0.0, 0.0, 1.0
    );
    
    return rz * ry * rx;
}

float box_sdf(vec3 p, vec3 b)
{
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    // Calculate animated transforms if enabled
    vec3 box_pos = this_filter.box_position;
    vec3 box_rot = this_filter.box_rotation;
    vec3 box_scl = this_filter.box_scale;
    
    // Transform vertex position to box space
    vec3 pos_world = position - box_pos;
    mat3 rot_mat_inv = transpose(rotation_matrix(box_rot));
    vec3 pos_box = rot_mat_inv * pos_world;
    
    // Apply scale inverse
    pos_box /= box_scl;
    
    // Calculate box dimensions
    vec3 box_size = (this_filter.box_max - this_filter.box_min) * 0.5;
    vec3 box_center = (this_filter.box_max + this_filter.box_min) * 0.5;
    
    // Check if position is inside/outside box with SDF
    float dist = box_sdf(pos_box - box_center, box_size);
    
    // Calculate crop factor based on mode and falloff
    float crop_factor = 1.0;
    
    if (this_filter.falloff_distance > 0.0) {
        // For falloff, we need to handle inside and outside modes differently
        if (this_filter.crop_mode == 0) { // Inside mode - keep what's inside
            if (dist <= 0.0) {
                // Inside the box - full visibility
                crop_factor = 1.0;
            }
            else {
                // Outside the box - apply falloff
                float normalized_dist = dist / this_filter.falloff_distance;
                normalized_dist = clamp(normalized_dist, 0.0, 1.0);
                
                // Apply falloff curve (inverted so 0 at far distance, 1 at boundary)
                if (this_filter.falloff_type == 0) { // Linear
                    crop_factor = 1.0 - normalized_dist;
                }
                else if (this_filter.falloff_type == 1) { // Smooth
                    crop_factor = smoothstep(1.0, 0.0, normalized_dist);
                }
            }
        }
        else { // Outside mode - keep what's outside
            if (dist > 0.0) {
                // Outside the box - full visibility
                crop_factor = 1.0;
            }
            else {
                // Inside the box - apply falloff
                float normalized_dist = -dist / this_filter.falloff_distance;
                normalized_dist = clamp(normalized_dist, 0.0, 1.0);
                
                // Apply falloff curve (inverted so 0 at center, 1 at boundary)
                if (this_filter.falloff_type == 0) { // Linear
                    crop_factor = 1.0 - normalized_dist;
                }
                else if (this_filter.falloff_type == 1) { // Smooth
                    crop_factor = smoothstep(1.0, 0.0, normalized_dist);
                }
                else { // Exponential
                    crop_factor = exp(-normalized_dist * 3.0);
                }
            }
        }
    }
    else {
        // Hard crop without falloff
        if (this_filter.crop_mode == 0) { // Inside mode
            crop_factor = (dist <= 0.0) ? 1.0 : 0.0;
        }
        else { // Outside mode
            crop_factor = (dist > 0.0) ? 1.0 : 0.0;
        }
    }
    
    // Apply cropping by scaling vertices towards/away from origin
    // For vertices that should be cropped (crop_factor = 0), move them to NaN
    if (crop_factor < 0.001) {
        position = vec3(0.0 / 0.0);
    }
    else if (crop_factor < 1.0 && this_filter.falloff_distance > 0.0) {
        // For falloff, modulate the alpha channel
        color.a *= crop_factor;
    }
}
