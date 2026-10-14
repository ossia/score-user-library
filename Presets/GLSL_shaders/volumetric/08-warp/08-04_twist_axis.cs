/*{
  "DESCRIPTION": "Twist around an axis: rotate xz by y\u00b7k. Spiral deformation of the volume. The output is rgba16f, so signed and HDR inputs (01-15 curl noise, the simulations, 07-06 Laplacian...) pass through without clipping.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "WARP"
  ],
  "INPUTS": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "twist",
      "TYPE": "float",
      "DEFAULT": 3.0,
      "MIN": -16.0,
      "MAX": 16.0,
      "LABEL": "Twist"
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
    }
  ],
  "RESOURCES": [
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

    float a;
    vec3 q = pc;
    if(axis == 0){
        a = twist * pc.x;
        mat2 R = mat2(cos(a),-sin(a),sin(a),cos(a));
        vec2 yz = R * pc.yz;
        q = vec3(pc.x, yz.x, yz.y);
    } else if(axis == 1){
        a = twist * pc.y;
        mat2 R = mat2(cos(a),-sin(a),sin(a),cos(a));
        vec2 xz = R * pc.xz;
        q = vec3(xz.x, pc.y, xz.y);
    } else {
        a = twist * pc.z;
        mat2 R = mat2(cos(a),-sin(a),sin(a),cos(a));
        vec2 xy = R * pc.xy;
        q = vec3(xy.x, xy.y, pc.z);
    }
    vec3 uvw = q*0.5 + 0.5;
    imageStore(volOut, pos, texture(volIn, uvw));

}
