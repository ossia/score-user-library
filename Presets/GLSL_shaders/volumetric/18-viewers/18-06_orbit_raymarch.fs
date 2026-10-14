/*{
  "DESCRIPTION": "Free-camera emission-absorption raymarch of a 3D volume inside a unit cube (front-to-back compositing, Beer-Lambert opacity per step), with ray-start jitter to hide step banding, tint, an ambient colour added to every sample in proportion to its opacity, brightness and gamma. The output is premultiplied (colour already weighted by the accumulated opacity) and transparent outside the volume, so it composites over whatever lies under it. Density is read from the alpha channel by default; set Density from to Luminance or a single channel for scalar volumes that store their field in RGB with alpha = 1 (most of the 01-05 generators), and raise Threshold to cut away low-density fog. Spin orbits the camera over time. This is the general-purpose viewer \u2014 use it first before reaching for 18-04 or 18-08. Volumes store premultiplied colour: with Density from = Alpha each sample's colour is unpremultiplied (divided by its alpha) before it is weighted by the step opacity, so thin fog keeps its colour instead of being darkened twice; the other modes treat RGB as a field and use it as stored.",
  "CREDIT": "ossia 3D catalog",
  "ISFVSN": "2.0",
  "ALPHA": "premultiplied",
  "CATEGORIES": [
    "3D-VIEWER"
  ],
  "INPUTS": [
    {
      "NAME": "volume",
      "TYPE": "image",
      "DIMENSIONS": 3,
      "LABEL": "Volume"
    },
    {
      "NAME": "yaw",
      "TYPE": "float",
      "DEFAULT": 0.6,
      "MIN": -3.14,
      "MAX": 3.14,
      "LABEL": "Yaw"
    },
    {
      "NAME": "pitch",
      "TYPE": "float",
      "DEFAULT": 0.3,
      "MIN": -1.5,
      "MAX": 1.5,
      "LABEL": "Pitch"
    },
    {
      "NAME": "zoom",
      "TYPE": "float",
      "DEFAULT": 2.5,
      "MIN": 1.2,
      "MAX": 6.0,
      "LABEL": "Zoom"
    },
    {
      "NAME": "steps",
      "TYPE": "long",
      "DEFAULT": 128,
      "MIN": 32,
      "MAX": 256,
      "LABEL": "Steps"
    },
    {
      "NAME": "density",
      "TYPE": "float",
      "DEFAULT": 3.0,
      "MIN": 0.1,
      "MAX": 16.0,
      "LABEL": "Density"
    },
    {
      "NAME": "brightness",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 4.0,
      "LABEL": "Brightness"
    },
    {
      "NAME": "gamma",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.4,
      "MAX": 2.4,
      "LABEL": "Gamma"
    },
    {
      "NAME": "tint",
      "TYPE": "color",
      "DEFAULT": [
        1.0,
        1.0,
        1.0,
        1.0
      ],
      "LABEL": "Tint"
    },
    {
      "NAME": "jitter",
      "TYPE": "float",
      "DEFAULT": 1.0,
      "MIN": 0.0,
      "MAX": 1.0,
      "LABEL": "Dither strength"
    },
    {
      "NAME": "densityFrom",
      "TYPE": "long",
      "DEFAULT": 0,
      "VALUES": [0, 1, 2, 3, 4],
      "LABELS": ["Alpha", "Luminance", "Red", "Green", "Blue"],
      "LABEL": "Density from"
    },
    {
      "NAME": "threshold",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": 0.0,
      "MAX": 0.95,
      "LABEL": "Threshold"
    },
    {
      "NAME": "spin",
      "TYPE": "float",
      "DEFAULT": 0.0,
      "MIN": -2.0,
      "MAX": 2.0,
      "LABEL": "Spin (rad/s)"
    },
    {
      "NAME": "ambient",
      "TYPE": "color",
      "DEFAULT": [
        0.08,
        0.1,
        0.15,
        1.0
      ],
      "LABEL": "Ambient"
    }
  ]
}*/

// Ray-box intersection against unit cube centered at origin
vec2 rayBox(vec3 ro, vec3 rd){
    vec3 inv = 1.0 / rd;
    vec3 t1 = (-vec3(0.5) - ro) * inv;
    vec3 t2 = ( vec3(0.5) - ro) * inv;
    vec3 tn = min(t1, t2);
    vec3 tf = max(t1, t2);
    return vec2(max(max(tn.x, tn.y), tn.z), min(min(tf.x, tf.y), tf.z));
}

// Cheap hash-based dither for ray-offset noise (kills stepping banding)
float hash12(vec2 p){
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void main()
{
    vec2 uv = isf_FragNormCoord * 2.0 - 1.0;
    uv.x *= RENDERSIZE.x / RENDERSIZE.y;
    // Camera matrix
    float yw = yaw + spin * TIME;
    vec3 ro = zoom * vec3(cos(pitch)*cos(yw), sin(pitch), cos(pitch)*sin(yw));
    vec3 fwd = -normalize(ro);
    // right = fwd x up: with up x fwd the screen basis is left-handed and
    // the picture comes out mirrored left-right.
    vec3 right = normalize(cross(fwd, vec3(0.0, 1.0, 0.0)));
    vec3 up = cross(right, fwd);
    vec3 rd = normalize(uv.x*right + uv.y*up + 1.5*fwd);
    vec2 tnf = rayBox(ro, rd);
    tnf.x = max(tnf.x, 0.0);
    if(tnf.x >= tnf.y){ isf_FragColor = vec4(0.0); return; }

    int N = int(steps);
    float dt = (tnf.y - tnf.x) / float(N);
    // Dither the starting offset by [0,1) voxel so neighbouring rays don't
    // sample the same planes — kills banding at low step counts.
    float jit = jitter * hash12(isf_FragCoord.xy + FRAMEINDEX * 0.0131);
    vec3 acc = vec3(0.0);
    float trans = 1.0;
    for(int i = 0; i < N; i++){
        vec3 wp = ro + rd*(tnf.x + (float(i) + jit) * dt);
        vec3 uvw = wp + 0.5;
        vec4 s = textureLod(volume, uvw, 0.0);
        float d = (densityFrom == 0) ? s.a
                : (densityFrom == 1) ? dot(s.rgb, vec3(0.2126, 0.7152, 0.0722))
                : (densityFrom == 2) ? s.r
                : (densityFrom == 3) ? s.g
                : s.b;
        d = max(d - threshold, 0.0) / (1.0 - threshold);
        float a = clamp(d * density * dt, 0.0, 1.0);
        vec3 c = (densityFrom == 0 && s.a > 0.0) ? s.rgb / s.a : s.rgb;
        acc += trans * (c * tint.rgb + ambient.rgb) * a;
        trans *= (1.0 - a);
        if(trans < 0.002) break;
    }
    acc *= brightness;
    acc = pow(max(acc, 0.0), vec3(1.0 / max(gamma, 0.01)));
    isf_FragColor = vec4(acc, 1.0 - trans);
}
