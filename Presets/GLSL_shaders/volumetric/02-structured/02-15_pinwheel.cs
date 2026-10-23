/*{
  "DESCRIPTION": "Radial pinwheel / spherical stripes: density from spherical coordinates (azimuth, polar angle).",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "STRUCTURED"
  ],
  "RESOURCES": [
    {
      "NAME": "azimuth",
      "TYPE": "float",
      "DEFAULT": 8.0,
      "MIN": 1.0,
      "MAX": 32.0,
      "LABEL": "Azimuth freq"
    },
    {
      "NAME": "polar",
      "TYPE": "float",
      "DEFAULT": 4.0,
      "MIN": 1.0,
      "MAX": 16.0,
      "LABEL": "Polar freq"
    },
    {
      "NAME": "spin",
      "TYPE": "float",
      "DEFAULT": 0.5,
      "MIN": 0.0,
      "MAX": 8.0,
      "LABEL": "Spin"
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
    float phi = atan(pc.y, pc.x) + TIME*spin;
    float theta = acos(clamp(pc.z/r, -1.0, 1.0));
    float v = 0.5 + 0.5*sin(phi*azimuth) * cos(theta*polar);
    imageStore(volume, pos, vec4(vec3(v), 1.0));

}
