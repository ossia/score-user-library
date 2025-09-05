/*{
  "DESCRIPTION": "FiboSound3D_fail - 3D fibo sphere...",
  "CREDIT": "hugo-w (ported from https://www.vertexshaderart.com/art/XTxHzHEnG5mRTTYnm)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 5614,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 10,
    "ORIGINAL_DATE": {
      "$date": 1619547907954
    }
  }
}*/

#define PI radians(180.)
#define PHI_A (3.-sqrt(5.))* PI

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 rotate(vec4 v, float a) {
  //mat4 rot = mat4(cos(a), sin(a), 0, 0,
   // -sin(a), cos(a), 0, 0,
 // 0, 0, 1, 0,
// 0, 0, 0, 1);
  mat4 rot = mat4(cos(a), sin(a), 0, 0,
        0, 1, 0, 0,
        -sin(a), cos(a), 1, 0,
        0, 0, 0, 1);
   vec4 res = rot * v;
  return res;
}

void main() {
  float scale = .35; // repeats/extends
  float size = 0.001; // stretch/squeeze
  float rad_max = (vertexCount * size);

  float y = floor(vertexId / 50.);
  float v = y/100.;
  float phi = acos(1. - 2. * v);

  float theta = PHI_A * vertexId;// * PHI_A;
  //float snd = texture(sound, vec2(cos(theta)/2.+.5, abs(sin(theta))*0.25));
  float snd = texture(sound, vec2(fract(theta / 35.0), fract(theta / 80000.0))).r;
  float radius = sqrt(vertexId * size) + snd*0.1;

  radius = radius * scale;

  float xoff = sin(time*0.8) * 0.8;
  float yoff = sin(time*1.3) * 0.1;
  gl_Position = rotate(vec4(cos(theta) * sin(phi) * radius,
        sin(theta) * sin(phi) * radius,
        cos(phi) * radius, 1), time * 0.5);

  float soff = pow(snd + 0.2, 8.);
  gl_PointSize = (soff + 2.) * sqrt(pow(resolution.x, 2.) + pow(resolution.y, 2.)) / 600.;

  float hue = snd*0.01 + time * 0.1;
  v_color = vec4(hsv2rgb(vec3(radius + hue, 1,
        1. // change step to 0. (all pass) for no blackening
        )), pow(snd, 5.));
}