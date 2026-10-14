/*{
  "DESCRIPTION": "HSV shift: rotate hue, scale saturation and value per voxel. Works on the straight (unpremultiplied) colour and premultiplies the result again. Saturation and value are clamped to [0, 1]; the output is rgba16f like the other volume filters.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "COLOR"
  ],
  "INPUTS": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "hueShift",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": -1.0,
      "MAX": 1.0,
      "LABEL": "Hue shift"
    },
    {
      "NAME": "sat",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 3.0,
      "LABEL": "Saturation"
    },
    {
      "NAME": "val",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 3.0,
      "LABEL": "Value"
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

vec3 rgb2hsv(vec3 c){
    vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
    vec4 q1 = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
    vec4 q  = c.r < q1.x ? vec4(q1.xyw, c.r) : vec4(c.r, q1.yzx);
    float d = q.x - min(q.w, q.y);
    float e = 1e-10;
    return vec3(abs(q.z + (q.w - q.y)/(6.0*d+e)), d/(q.x+e), q.x);
}
vec3 hsv2rgb(vec3 c){
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz)*6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 unpremultiply(vec4 c){ return c.a > 0.0 ? c.rgb / c.a : vec3(0.0); }

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volOut);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);
    vec3 pc = p * 2.0 - 1.0;

    vec4 s = texture(volIn, p);
    vec3 h = rgb2hsv(unpremultiply(s));
    h.x = fract(h.x + hueShift);
    h.y = clamp(h.y * sat, 0.0, 1.0);
    h.z = clamp(h.z * val, 0.0, 1.0);
    imageStore(volOut, pos, vec4(hsv2rgb(h) * s.a, s.a));

}
