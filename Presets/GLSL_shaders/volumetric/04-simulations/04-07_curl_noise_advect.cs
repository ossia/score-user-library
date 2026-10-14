/*{
  "DESCRIPTION": "Advection of a scalar density through a time-varying curl-noise velocity field. Curl of a noise potential is divergence-free, so the density swirls without compressing. Three coloured blobs are continuously re-injected \u2014 they get stirred by the noise. Extraordinary organic motion, looks like abstract ink in water. Output: RGB = dye colour, A = dye amount (both advected), so any viewer reading density from alpha shows the ink.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "MODE": "COMPUTE_SHADER",
  "CATEGORIES": [
    "3D-GENERATOR",
    "SIMULATION"
  ],
  "INPUTS": [
    {
      "NAME": "noiseScale",
      "TYPE": "float",
      "DEFAULT": 1.3,
      "MIN": 0.2,
      "MAX": 6.0,
      "LABEL": "Noise scale"
    },
    {
      "NAME": "noiseSpeed",
      "TYPE": "float",
      "DEFAULT": 0.15,
      "MIN": 0.0,
      "MAX": 1.0,
      "LABEL": "Noise evolution"
    },
    {
      "NAME": "velScale",
      "TYPE": "float",
      "DEFAULT": 1.5,
      "MIN": 0.1,
      "MAX": 8.0,
      "LABEL": "Velocity scale"
    },
    {
      "NAME": "decay",
      "TYPE": "float",
      "DEFAULT": 0.993,
      "MIN": 0.9,
      "MAX": 1.0,
      "LABEL": "Decay"
    },
    {
      "NAME": "dt",
      "TYPE": "float",
      "DEFAULT": 0.03,
      "MIN": 0.001,
      "MAX": 0.1,
      "LABEL": "Timestep"
    }
  ],
  "RESOURCES": [
    {
      "NAME": "state",
      "TYPE": "image",
      "ACCESS": "read_write",
      "FORMAT": "rgba16f",
      "WIDTH": "64",
      "HEIGHT": "64",
      "DEPTH": "64",
      "PERSISTENT": true
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
        "TARGET": "state"
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

vec3 pot(in vec3 q){
    return vec3(snoise(q + vec3(31.4, 0.0, 0.0)),
                snoise(q + vec3(0.0, 41.2, 0.0)),
                snoise(q + vec3(0.0, 0.0, 53.7)));
}
vec3 curlNoise(in vec3 q){
    const float e = 0.05;
    vec3 dx = vec3(e,0,0), dy = vec3(0,e,0), dz = vec3(0,0,e);
    vec3 px1=pot(q+dx), px0=pot(q-dx);
    vec3 py1=pot(q+dy), py0=pot(q-dy);
    vec3 pz1=pot(q+dz), pz0=pot(q-dz);
    return vec3((py1.z-py0.z)-(pz1.y-pz0.y),
                (pz1.x-pz0.x)-(px1.z-px0.z),
                (px1.y-px0.y)-(py1.x-py0.x)) / (2.0*e);
}

void main()
{
    ivec3 pos  = ivec3(gl_GlobalInvocationID.xyz);
    ivec3 size = imageSize(state);
    if(any(greaterThanEqual(pos, size))) return;
    vec3  p    = (vec3(pos) + 0.5) / vec3(size);
    vec3  pc   = p * 2.0 - 1.0;
    vec4  prev = imageLoad(state_prev, pos);

    // Seed on the first dispatch. score currently starts FRAMEINDEX at 1, not
    // at 0 as the ISF spec says (see showcase/volume/_engine); <= 1 works either way.
    if(FRAMEINDEX <= 1){
        imageStore(state, pos, vec4(0.0));
        return;
    }
    // Curl-noise velocity
    vec3 vel = curlNoise(pc * noiseScale + vec3(TIME * noiseSpeed)) * velScale;
    vec3 pcBack = pc - vel * dt;
    vec3 backUV = pcBack * 0.5 + 0.5;
    ivec3 backVoxel = clamp(ivec3(backUV * vec3(size)), ivec3(0), size - 1);
    vec4 advected = imageLoad(state_prev, backVoxel);
    // Inject three orbiting coloured blobs
    float t = TIME;
    vec3 c1 = 0.35 * vec3(sin(t*0.7),  cos(t*0.9+1.0), sin(t*1.1+2.0));
    vec3 c2 = 0.35 * vec3(cos(t*1.3),  sin(t*0.6+3.0), cos(t*0.8+1.5));
    vec3 c3 = 0.35 * vec3(sin(t*0.5+1.7), cos(t*1.1), sin(t*0.9+0.5));
    float s = 0.12;
    float r1 = length(pc - c1);
    float r2 = length(pc - c2);
    float r3 = length(pc - c3);
    vec3 inject = exp(-r1*r1/(s*s)) * vec3(1.0, 0.3, 0.1)
                + exp(-r2*r2/(s*s)) * vec3(0.1, 1.0, 0.4)
                + exp(-r3*r3/(s*s)) * vec3(0.3, 0.2, 1.0);
    vec4 next = advected * decay + vec4(inject, max(inject.r, max(inject.g, inject.b))) * 0.25;
    next = clamp(next, 0.0, 2.0);

    imageStore(state, pos, next);
}
