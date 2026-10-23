/*{
  "DESCRIPTION": "Volumetric brick wall: offset rows per layer. Adjustable brick scale and mortar.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "RESOURCES": [
    {
      "NAME": "scaleX",
      "TYPE": "float",
      "DEFAULT": 8.0,
      "MIN": 1.0,
      "MAX": 32.0,
      "LABEL": "Bricks X"
    },
    {
      "NAME": "scaleY",
      "TYPE": "float",
      "DEFAULT": 4.0,
      "MIN": 1.0,
      "MAX": 32.0,
      "LABEL": "Bricks Y"
    },
    {
      "NAME": "scaleZ",
      "TYPE": "float",
      "DEFAULT": 4.0,
      "MIN": 1.0,
      "MAX": 32.0,
      "LABEL": "Bricks Z"
    },
    {
      "NAME": "mortar",
      "TYPE": "float",
      "DEFAULT": 0.05,
      "MIN": 0.0,
      "MAX": 0.3,
      "LABEL": "Mortar"
    },
    {
      "NAME": "volume",
      "TYPE": "image",
      "ACCESS": "write_only",
      "WIDTH": "64",
      "HEIGHT": "64",
      "DEPTH": "64"
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
        "TARGET": "volume"
      }
    }
  ]
}*/

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    vec3 q = p * vec3(scaleX, scaleY, scaleZ);
    q.x += 0.5 * mod(floor(q.y) + floor(q.z), 2.0);
    vec3 f = fract(q);
    float mX = step(mortar, f.x) * step(f.x, 1.0 - mortar);
    float mY = step(mortar, f.y) * step(f.y, 1.0 - mortar);
    float mZ = step(mortar, f.z) * step(f.z, 1.0 - mortar);
    float v = mX * mY * mZ;
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
