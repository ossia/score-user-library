/*{
  "DESCRIPTION": "voices - soundcloud link updated",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/bG8faYzBsvfvBSwDH)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 25600,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 144,
    "ORIGINAL_DATE": {
      "$date": 1446348066727
    }
  }
}*/

#define NUM_SEGMENTS 64.0
#define NUM_POINTS (NUM_SEGMENTS * 2.)
#define PI 3.14159

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec2 mouthLine(float vertexId) {
  vertexId = mod(vertexId, NUM_SEGMENTS);
  float rt = floor(vertexId / (NUM_SEGMENTS * .5));
  float bot = mod(floor(vertexId / (NUM_SEGMENTS * .25)), 2.);
  float u = mod(vertexId, NUM_SEGMENTS * .25) / (NUM_SEGMENTS * .25);
  bot = mix(bot, 1. - bot, rt);
  // 0, 1, 2, 3
  // 3, 2, 1, 0, 0, -1, -2, -3,
  // -3, -2, -1, 0
  float uh = mix(mix(u, 1. - u, bot), mix(-u, -1. + u,1. - bot), rt);
  float v = mix(sin((0.2 + abs(uh) * 0.7) * PI) - 0.3, sin((0.4 + abs(uh) * 0.6) * PI), bot);
  return vec2(uh, mix(v, -v, bot));
}

vec2 mouth(float vertexId) {
  float inOut = mod(floor(vertexId / NUM_POINTS), 2.);
  // produces 0,1, 1,2, 2,3, ...
  float point = floor(mod(vertexId, NUM_POINTS) / 2.0) + mod(vertexId, 2.0);
  return mouthLine(point) * mix(vec2(1., 1.), vec2(1., .5), inOut);
}

void main() {
  float inOut = mod(floor(vertexId / NUM_POINTS), 2.);
  // produces 0,1, 1,2, 2,3, ...
  float point = floor(mod(vertexId, NUM_POINTS) / 2.0) + mod(vertexId, 2.0);
  // line count
  float count = mod(floor(vertexId / (NUM_POINTS * 2.)), 10.);
  float mEcho = floor(vertexId / (NUM_POINTS * 2. * 10.));
  float snd = texture(sound, vec2(count / 10. * 0.1, 0.)).r;

  //vec2 rp = vec2(count / 10.0, 0.5);
  float posId = count + floor(time * 0.1 + count * 0.1) * 10.;
  float scale = rand(vec2(posId * .3, posId * 1.3));
  vec2 rp = vec2(rand(vec2(posId, posId)), rand(vec2(posId*7.,posId*9.)));
  float mLerp = mEcho / 10.;
  float sndScale = mix(0.7, 2.3, pow(snd + 0.3, 5.0));
  vec2 xy = mouth(vertexId) * vec2(1. + sndScale * 0.05, sndScale) * mix(0.3, 1.2, scale) * mix(1., .6, mLerp) + (rp * 2. - 1.) * 4.;

  gl_Position = vec4(xy * 0.20, 0, 1);
  gl_PointSize = 4.;

  float hue = -0.08 + count * 0.01;
  float sat = 1.0;
  float val = pow(1. - mLerp, 3.) * mix(0.3, 1.0, snd);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}