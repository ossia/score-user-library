/*{
  "DESCRIPTION": "Rotation + zoom feedback: resample prev with a rotation around Y and a uniform zoom. Classic zoomer. The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
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
      "NAME": "current",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Current frame (3D)"
    },
    {
      "NAME": "zoom",
      "TYPE": "float",
      "DEFAULT": 1.02,
      "MIN": 0.7,
      "MAX": 1.5,
      "LABEL": "Zoom"
    },
    {
      "NAME": "rot",
      "TYPE": "float",
      "DEFAULT": 0.03,
      "MIN": -0.5,
      "MAX": 0.5,
      "LABEL": "Rot (rad)"
    },
    {
      "NAME": "persistence",
      "TYPE": "float",
      "DEFAULT": 0.85,
      "MIN": 0.0,
      "MAX": 1.0,
      "LABEL": "Persistence"
    }
  ],
  "RESOURCES": [
    {
      "NAME": "volOut",
      "TYPE": "image",
      "ACCESS": "write_only",
      "FORMAT": "rgba16f",
      "WIDTH": "$WIDTH_current",
      "HEIGHT": "$HEIGHT_current",
      "DEPTH": "$DEPTH_current"
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
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);
    vec3 pc = p * 2.0 - 1.0;

    float a = rot;
    mat2 R = mat2(cos(a),-sin(a), sin(a),cos(a));
    vec3 q = pc / zoom;
    q.xz = R * q.xz;
    vec4 pr = texture(prev, q*0.5 + 0.5) * persistence;
    vec4 cu = texture(current, p);
    imageStore(volOut, pos, max(pr, cu));

}
