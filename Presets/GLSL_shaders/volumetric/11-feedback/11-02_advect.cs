/*{
  "DESCRIPTION": "Semi-Lagrangian advection: each voxel takes the value of 'prev' at p - velocity x Dt (in volume units), so the content is carried along the velocity field. By default the velocity volume is read as RGB = 0.5 + v/2, the encoding of 17-06 schlieren; tick Signed velocity for a signed float field such as 01-15 curl noise. Feed the output back into 'prev' (through a delayed cable) for fluid-like transport. The output is rgba16f, so a signed or HDR advected volume is not clipped.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "FEEDBACK-LIKE"
  ],
  "INPUTS": [
    {
      "NAME": "prev",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Previous frame (3D)"
    },
    {
      "NAME": "velocity",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Velocity field (3D)"
    },
    {
      "NAME": "dt",
      "TYPE": "float",
      "DEFAULT": 0.015,
      "MIN": 0.0,
      "MAX": 0.2,
      "LABEL": "Dt"
    },
    {
      "NAME": "signedVelocity",
      "TYPE": "bool",
      "DEFAULT": false,
      "LABEL": "Signed velocity (else 0.5 + v/2)"
    }
  ],
  "RESOURCES": [
    {
      "NAME": "volOut",
      "TYPE": "image",
      "ACCESS": "write_only",
      "FORMAT": "rgba16f",
      "WIDTH": "$WIDTH_velocity",
      "HEIGHT": "$HEIGHT_velocity",
      "DEPTH": "$DEPTH_velocity"
    }
  ],
  "PASSES": [
    {
      "LOCAL_SIZE": [
        4,
        4,
        4
      ],
      "EXECUTION_MODEL": {
        "TYPE": "3D_IMAGE",
        "TARGET": "volOut"
      }
    }
  ]
}*/

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volOut);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p = (vec3(pos)+0.5)/vec3(size);
    vec3 v = texture(velocity, p).rgb;
    if(!signedVelocity) v = v * 2.0 - 1.0;
    vec3 back = p - v * dt;
    imageStore(volOut, pos, texture(prev, back));
}
