/*{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/fdV3zW by supah.  Disco lights",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": 28.9,
            "LABEL": "permuteRate",
            "MAX": 50,
            "MIN": -50,
            "NAME": "permuteRate",
            "TYPE": "float"
        },
        {
            "DEFAULT": 7,
            "LABEL": "gFactor",
            "MAX": 50,
            "MIN": -50,
            "NAME": "gFactor",
            "TYPE": "float"
        },
        {
            "DEFAULT": 2.2,
            "LABEL": "fadeFactor",
            "MAX": 5,
            "MIN": -5,
            "NAME": "fadeFactor",
            "TYPE": "float"
        },
        {
            "DEFAULT": 2.2,
            "LABEL": "amp",
            "MAX": 5,
            "MIN": -5,
            "NAME": "amp",
            "TYPE": "float"
        },
        {
            "DEFAULT": 34,
            "LABEL": "smoothing",
            "MAX": 50,
            "MIN": -50,
            "NAME": "smoothing",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "LABEL": "xPos",
            "MAX": 1,
            "MIN": -1,
            "NAME": "xPos",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.2,
            "LABEL": "yPos",
            "MAX": 1,
            "MIN": -1,
            "NAME": "yPos",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.02,
            "LABEL": "zPos",
            "MAX": 1,
            "MIN": -1,
            "NAME": "zPos",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "LABEL": "yPosNoise",
            "MAX": 3,
            "MIN": -1,
            "NAME": "yPosNoise",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "LABEL": "uvPos",
            "MAX": 3,
            "MIN": -3,
            "NAME": "uvPos",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.3,
            "LABEL": "lumi",
            "MAX": 1.01,
            "MIN": 0.09,
            "NAME": "lumi",
            "TYPE": "float"
        },
        {
            "DEFAULT": 30,
            "LABEL": "numPlots",
            "MAX": 100,
            "MIN": 1,
            "NAME": "numPlots",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "rotation",
            "MAX": 6.28,
            "MIN": -6.28,
            "NAME": "rotation",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.0073,
            "LABEL": "cut",
            "MAX": 0.05,
            "MIN": 0.001,
            "NAME": "cut",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                1,
                1,
                1,
                1
            ],
            "LABEL": "color",
            "MAX": [
                1,
                1,
                1,
                1
            ],
            "MIN": [
                0,
                0,
                0,
                1
            ],
            "NAME": "color",
            "TYPE": "color"
        }
    ],
    "ISFVSN": "2"
}
*/


// float permuteRate = 289.; // 289.
// float gFactor = 7.; // 7.
// float fadeFactor = 2.2; // 2.2
// float amp = 2.2; // 2.2
// float smoothing = 34.; // 34.0
// float xPos = .5; // 0.5
// float yPos = .2; // 0.2
// float zPos = 0.02; // 0.02
// float yPosNoise = .5; // 0.5
// float uvPos = 0.5; // 0.5
// float lumi = 0.3; // 0.3
// float numPlots = 30.; // 30.
// float cut = 0.0073; // 0.0073

mat2 rotate(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

vec4 permute(vec4 x) {
    return mod(((x * smoothing) + 1.) * x, permuteRate);
}

vec4 taylorInvSqrt(vec4 r) {
    // return 1.79284291400159 - 0.85373472095314 * r;
    return (1.79284291400159 - 0.85373472095314 * r) * amp;
}

vec3 fade(vec3 t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

float cnoise(vec3 P){
  vec3 Pi0 = floor(P); // Integer part for indexing
  vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1

  Pi0 = mod(Pi0, permuteRate);
  Pi1 = mod(Pi1, permuteRate);

  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0

  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 / gFactor;
  vec4 gy0 = fract(floor(gx0) / gFactor) - yPosNoise;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(yPosNoise) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - yPosNoise);
  gy0 -= sz0 * (step(0.0, gy0) - yPosNoise);

  vec4 gx1 = ixy1 / gFactor;
  vec4 gy1 = fract(floor(gx1) / gFactor) - yPosNoise;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(yPosNoise) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - yPosNoise);
  gy1 -= sz1 * (step(0.0, gy1) - yPosNoise);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return fadeFactor * n_xyz;
}

float plot(vec2 st, float pct){
  return  smoothstep( pct - cut, pct, st.y) -
          smoothstep( pct, pct + cut, st.y);
}

void main() {

    vec2 uv =(gl_FragCoord.xy - 0.5 * RENDERSIZE.xy)/RENDERSIZE.y; // -uvPos <> uvPos
    uv *= rotate(rotation);
    vec3 col = vec3(0.);
    for (float i = 0.; i < numPlots; i += 1.) {
        float inc = i / numPlots;

        float px = smoothstep(xPos, 0., .4 * length(uv)) * 4. + TIME;
        float py = yPos * TIME + yPos * uv.x;
        vec3 P = vec3(px, py, -i * zPos);

        float l = plot(uv * uvPos, 0.13 * cnoise(P));

        vec3 c = mix(vec3(color.r, uv.x + uvPos * color.g, 1. - uv.x * color.b), vec3(uv.x + uvPos, color.g, uvPos - uv.x), inc);

        col += vec3(l * c * lumi);
    }
    
    // Output to screen
    gl_FragColor = vec4(col, 1.);
}
