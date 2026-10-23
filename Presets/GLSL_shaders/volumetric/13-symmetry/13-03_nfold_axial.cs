/*{
  "DESCRIPTION": "N-fold rotational symmetry around an axis: fold the azimuthal angle into a wedge of 2\u03c0/N, then mirror. Mirror halves additionally mirrors one half of the volume onto the other along the axis (around Y: the top onto the bottom), for a crystal-like kaleidoscope; axis Y with Mirror halves on replaces the former 08-09_kaleidoscope3d (archived). The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "SYMMETRY"
  ],
  "RESOURCES": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "folds",
      "TYPE": "long",
      "DEFAULT": 6,
      "MIN": 2,
      "MAX": 16,
      "LABEL": "N folds"
    },
    {
      "NAME": "axis",
      "TYPE": "long",
      "DEFAULT": 1,
      "VALUES": [
        0,
        1,
        2
      ],
      "LABELS": [
        "X",
        "Y",
        "Z"
      ],
      "LABEL": "Axis"
    },
    {
      "NAME": "mirror",
      "TYPE": "bool",
      "DEFAULT": false,
      "LABEL": "Mirror halves along the axis"
    },
    {
      "NAME": "volOut",
      "TYPE": "image",
      "ACCESS": "write_only",
      "FORMAT": "rgba16f",
      "WIDTH": "$WIDTH_volIn",
      "HEIGHT": "$HEIGHT_volIn",
      "DEPTH": "$DEPTH_volIn"
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

    vec3 q = pc;
    float sec = 3.14159265 / float(folds);
    if(axis == 0){
        float r = length(q.yz);
        float a = atan(q.z, q.y);
        a = mod(a + sec, 2.0*sec) - sec;
        a = abs(a);
        q.y = r*cos(a); q.z = r*sin(a);
    } else if(axis == 1){
        float r = length(q.xz);
        float a = atan(q.z, q.x);
        a = mod(a + sec, 2.0*sec) - sec;
        a = abs(a);
        q.x = r*cos(a); q.z = r*sin(a);
    } else {
        float r = length(q.xy);
        float a = atan(q.y, q.x);
        a = mod(a + sec, 2.0*sec) - sec;
        a = abs(a);
        q.x = r*cos(a); q.y = r*sin(a);
    }
    if(mirror){
        if(axis == 0)      q.x = abs(q.x);
        else if(axis == 1) q.y = abs(q.y);
        else               q.z = abs(q.z);
    }
    imageStore(volOut, pos, texture(volIn, q*0.5 + 0.5));

}
