/*{
  "CREDIT": "ossia score",
  "ISFVSN": "2",
  "DESCRIPTION": "World-space triplanar UV mapping",
  "MODE": "GEOMETRY_FILTER",
  "CATEGORIES": [ "Geometry Effect", "UV", "World Space" ],
  "INPUTS": [
    {
      "NAME": "triplanar_scale",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 10.0
    },
    {
      "NAME": "blend_sharpness",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 10.0
    },
    {
      "NAME": "offset_x",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": -10.0,
      "MAX": 10.0
    },
    {
      "NAME": "offset_y",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": -10.0,
      "MAX": 10.0
    },
    {
      "NAME": "offset_z",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": -10.0,
      "MAX": 10.0
    },
    {
      "NAME": "use_world_position",
      "TYPE": "bool",
      "DEFAULT": true
    },
    {
      "NAME": "animation_speed",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": 0.0,
      "MAX": 5.0
    },
    {
      "NAME": "separate_scales",
      "TYPE": "bool",
      "DEFAULT": false
    },
    {
      "NAME": "scale_x_plane",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 10.0
    },
    {
      "NAME": "scale_y_plane",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 10.0
    },
    {
      "NAME": "scale_z_plane",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 10.0
    }
  ]
}*/

void process_vertex(inout vec3 position, inout vec3 normal, inout vec2 uv, inout vec3 tangent, inout vec4 color)
{
    // Use world position for triplanar mapping
    vec3 world_pos = this_filter.use_world_position ? position : position;
    
    // Add animation offset
    vec3 animated_offset = vec3(
        this_filter.offset_x + TIME * this_filter.animation_speed * 0.1,
        this_filter.offset_y + TIME * this_filter.animation_speed * 0.07,
        this_filter.offset_z + TIME * this_filter.animation_speed * 0.13
    );
    
    world_pos += animated_offset;
    
    // Calculate triplanar UV coordinates for each plane
    vec2 uv_x, uv_y, uv_z;
    
    if (this_filter.separate_scales) {
        uv_x = world_pos.yz * this_filter.scale_x_plane; // YZ plane (facing X)
        uv_y = world_pos.xz * this_filter.scale_y_plane; // XZ plane (facing Y) 
        uv_z = world_pos.xy * this_filter.scale_z_plane; // XY plane (facing Z)
    } else {
        uv_x = world_pos.yz * this_filter.triplanar_scale;
        uv_y = world_pos.xz * this_filter.triplanar_scale;
        uv_z = world_pos.xy * this_filter.triplanar_scale;
    }
    
    // Calculate blend weights based on normal
    vec3 abs_normal = abs(normal);
    vec3 blend_weights = pow(abs_normal, vec3(this_filter.blend_sharpness));
    
    // Normalize blend weights so they sum to 1
    blend_weights /= (blend_weights.x + blend_weights.y + blend_weights.z);
    
    // Store blend weights in vertex color for fragment shader use
    // This allows the fragment shader to blend between the three projections
    color.rgb = blend_weights;
    
    // Store the primary UV based on the dominant normal direction
    if (abs_normal.x > abs_normal.y && abs_normal.x > abs_normal.z) {
        // X-facing surface
        uv = uv_x;
    }
    else if (abs_normal.y > abs_normal.z) {
        // Y-facing surface  
        uv = uv_y;
    }
    else {
        // Z-facing surface
        uv = uv_z;
    }
    
    // For a complete triplanar implementation, the fragment shader would need
    // to sample the texture three times (once for each projection) and blend
    // them using the weights stored in color.rgb
}