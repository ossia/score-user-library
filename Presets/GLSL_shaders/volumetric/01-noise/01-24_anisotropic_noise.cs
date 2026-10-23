/*{
  "DESCRIPTION": "Directionally-stretched simplex noise: the sampling space is compressed along a user-chosen axis so the resulting structure has a strong grain direction. Useful for wood-grain, fur, brushed-metal, and motion-streak looks. Stretch amount controls aspect ratio (1 = isotropic, 8 = very elongated).",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "NOISE"
  ],
  "RESOURCES": [
    {
      "NAME": "scale",
      "TYPE": "float",
      "DEFAULT": 3.0,
      "MIN": 0.5,
      "MAX": 12.0,
      "LABEL": "Scale"
    },
    {
      "NAME": "direction",
      "TYPE": "point3D",
      "DEFAULT": [
        1.0,
        0.0,
        0.0
      ],
      "MIN": [
        -1,
        -1,
        -1
      ],
      "MAX": [
        1,
        1,
        1
      ],
      "LABEL": "Grain direction"
    },
    {
      "NAME": "stretch",
      "TYPE": "float",
      "DEFAULT": 4.0,
      "MIN": 1.0,
      "MAX": 16.0,
      "LABEL": "Stretch factor"
    },
    {
      "NAME": "drift",
      "TYPE": "float",
      "DEFAULT": 0.2,
      "MIN": 0.0,
      "MAX": 3.0,
      "LABEL": "Drift"
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

// Simplex 3D noise (Ashima Arts, ISC-licensed, widely used)
vec4 mod289(vec4 x){return x-floor(x*(1.0/289.0))*289.0;}
vec3 mod289(vec3 x){return x-floor(x*(1.0/289.0))*289.0;}
vec4 permute(vec4 x){return mod289(((x*34.0)+1.0)*x);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159-0.85373472095314*r;}
float snoise(vec3 v){
    const vec2 C = vec2(1.0/6.0, 1.0/3.0);
    const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);
    vec3 i  = floor(v + dot(v, C.yyy));
    vec3 x0 = v - i + dot(i, C.xxx);
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min(g.xyz, l.zxy);
    vec3 i2 = max(g.xyz, l.zxy);
    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy;
    vec3 x3 = x0 - D.yyy;
    i = mod289(i);
    vec4 p = permute(permute(permute(
         i.z + vec4(0.0, i1.z, i2.z, 1.0))
       + i.y + vec4(0.0, i1.y, i2.y, 1.0))
       + i.x + vec4(0.0, i1.x, i2.x, 1.0));
    float n_ = 0.142857142857;
    vec3 ns = n_ * D.wyz - D.xzx;
    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);
    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_);
    vec4 x = x_ *ns.x + ns.yyyy;
    vec4 y = y_ *ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);
    vec4 b0 = vec4(x.xy, y.xy);
    vec4 b1 = vec4(x.zw, y.zw);
    vec4 s0 = floor(b0)*2.0 + 1.0;
    vec4 s1 = floor(b1)*2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));
    vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww;
    vec3 p0 = vec3(a0.xy, h.x);
    vec3 p1 = vec3(a0.zw, h.y);
    vec3 p2 = vec3(a1.xy, h.z);
    vec3 p3 = vec3(a1.zw, h.w);
    vec4 norm = taylorInvSqrt(vec4(dot(p0,p0),dot(p1,p1),dot(p2,p2),dot(p3,p3)));
    p0 *= norm.x; p1 *= norm.y; p2 *= norm.z; p3 *= norm.w;
    vec4 m = max(0.6 - vec4(dot(x0,x0),dot(x1,x1),dot(x2,x2),dot(x3,x3)), 0.0);
    m = m * m;
    return 42.0 * dot(m*m, vec4(dot(p0,x0),dot(p1,x1),dot(p2,x2),dot(p3,x3)));
}

void main()
{
    ivec3 pos = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(volume);
    if(any(greaterThanEqual(pos, size))) return;
    vec3 p  = (vec3(pos) + 0.5) / vec3(size);   // [0,1]^3
    vec3 pc = p * 2.0 - 1.0;                     // [-1,1]^3

    // Build an orthonormal basis with `u` pointing along `direction`
    vec3 u = normalize(direction + 1e-5);
    vec3 vref = (abs(u.y) < 0.9) ? vec3(0.0, 1.0, 0.0) : vec3(1.0, 0.0, 0.0);
    vec3 v_ax = normalize(cross(u, vref));
    vec3 w_ax = cross(u, v_ax);
    // Decompose pc into (along, perp_v, perp_w). Compress the along-axis so
    // equal traversal in world space = smaller traversal in noise space,
    // which makes the noise *stretched* along that direction.
    vec3 q;
    q.x = dot(pc, u) / stretch;
    q.y = dot(pc, v_ax);
    q.z = dot(pc, w_ax);
    float n = snoise(q * scale + vec3(TIME * drift));
    n = n * 0.5 + 0.5;
    imageStore(volume, pos, vec4(vec3(n), 1.0));

}
