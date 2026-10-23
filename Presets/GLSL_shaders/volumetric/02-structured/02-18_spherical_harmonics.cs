/*{
  "DESCRIPTION": "Real spherical harmonics-like function: sin(theta)^|m| * cos((l-|m|)*theta) * cos/sin(m*phi). Produces pulsing flower / bloom shapes.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "RESOURCES": [
    {
      "NAME": "l1",
      "TYPE": "long",
      "DEFAULT": 4,
      "MIN": 0,
      "MAX": 8,
      "LABEL": "Band l"
    },
    {
      "NAME": "m1",
      "TYPE": "long",
      "DEFAULT": 2,
      "MIN": -6,
      "MAX": 6,
      "LABEL": "Order m"
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

    float r = length(pc) + 1e-6;
    float theta = acos(clamp(pc.z/r, -1.0, 1.0));
    float phi = atan(pc.y, pc.x);
    int L = int(l1), M = int(m1);
    float am = float(abs(M));
    float leg = pow(sin(theta), am) * cos(float(L - int(am)) * theta);
    float azi = (M >= 0) ? cos(am*phi) : sin(am*phi);
    float y = leg * azi;
    float v = abs(y) * exp(-r*r*1.2);
    imageStore(volume, pos, vec4(vec3(clamp(v*1.5, 0.0, 1.0)), 1.0));

}
