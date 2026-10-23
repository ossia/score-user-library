/*{
  "DESCRIPTION": "HDR tone mapping. Three operators: Reinhard (x / (1 + x)), ACES approximation (cinematic), Uncharted2 (John Hable's filmic curve). Apply after operators that produce >1.0 values (normal lighting, cosine palette at large amp, emission raymarcher intermediates). The operator works on the straight (unpremultiplied) colour and the result is premultiplied again. The HDR input is read at full precision; the mapped colour is clamped to [0, 1] and stored rgba16f like the other volume filters, so dark gradients do not band.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-FILTER",
    "COLOR"
  ],
  "RESOURCES": [
    {
      "NAME": "volIn",
      "TYPE": "texture",
      "DIMENSIONS": 3,
      "LABEL": "Input volume"
    },
    {
      "NAME": "operator",
      "TYPE": "long",
      "DEFAULT": 1,
      "VALUES": [
        0,
        1,
        2
      ],
      "LABELS": [
        "Reinhard",
        "ACES",
        "Uncharted2"
      ],
      "LABEL": "Operator"
    },
    {
      "NAME": "exposure",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.1,
      "MAX": 8.0,
      "LABEL": "Exposure"
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

vec3 aces(vec3 x){
    const float a = 2.51;
    const float b = 0.03;
    const float c = 2.43;
    const float d = 0.59;
    const float e = 0.14;
    return clamp((x*(a*x+b)) / (x*(c*x+d)+e), 0.0, 1.0);
}
vec3 uncharted2(vec3 x){
    const float A = 0.15, B = 0.50, C = 0.10, D = 0.20, E = 0.02, F = 0.30;
    return ((x*(A*x+C*B)+D*E) / (x*(A*x+B)+D*F)) - E/F;
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
    vec3 c = unpremultiply(s) * exposure;
    vec3 mapped = c;
    if(operator == 0){
        mapped = c / (1.0 + c);
    } else if(operator == 1){
        mapped = aces(c);
    } else {
        const float W = 11.2;
        vec3 whiteScale = 1.0 / uncharted2(vec3(W));
        mapped = uncharted2(c) * whiteScale;
    }
    imageStore(volOut, pos, vec4(clamp(mapped, 0.0, 1.0) * s.a, s.a));

}
