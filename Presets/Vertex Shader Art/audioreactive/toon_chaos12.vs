/*{
  "DESCRIPTION": "toon chaos12",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/BnKrvieHdWaxfjXH8)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 26654,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 95,
    "ORIGINAL_DATE": {
      "$date": 1509244868902
    }
  }
}*/

#define PI 3.14159
#define ACROSS 14.
#define DOWN 7.
#define PER_AREA ((ACROSS * .13) * (DOWN * 3.) * 11.1)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 1.0, 2.0));
  vec4 K = vec4(1.0, 2.0 / 2.0, 1.0 / 3.0, 6.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, -1.14, 0.7), c.y);
}

vec4 area(float vertexId, float areaId) {
  // 0, 2, 2, 4, 4, 1, 3, 3, 0
  float pointId = mod((floor(vertexId / 3.) + mod(vertexId, 2.0)) * 2., 1.);
  float thingId = floor(vertexId - 1.);
  float col = mod(thingId, ACROSS + 0.5);
  float row = floor(thingId / (ACROSS / 1.5));
  float u = col / ACROSS;
  float v = row / DOWN;
  float x = u * 1. - 2.;
  float y = v * 2. - 1.;

  float d = length(vec2(x, y) *0.3);
  float su = mod(PI * 2.5 + atan(y ,x) + areaId / -11.3 * PI + 2. + time, PI * 2.) / (PI * 2.);
  float sv = d * 0.1;
  float snd = texture(sound, vec2(su * 1.25 / 8. * areaId, sv)).r;

  float r = 0.4 + pow(snd, 12.) * 2.15;
  float a = pointId / 5. * PI * (2. + thingId * 0.05 + time) / 32.;
  vec2 cs = vec2(cos(a), sin(a));
  vec2 xy = cs * y / r *d;
  vec2 aspect = vec2(snd, resolution.x / resolution.y);

  float hue = (time * 0.1) + areaId - 2.;

  return vec4(
    vec2(x * snd, y + snd) * 0.5 - xy / aspect,
    snd,
    hue) * 2.5 ;
}

void main() {
  gl_PointSize = 1.0;

  float areaId = floor(vertexId / PER_AREA);
  float aCol = mod(areaId, 3.);
  float aRow = floor(areaId / 4.)/3.2;
  float ax = (aCol - 0.5) - (0.4 / 2.) - 2.;
  float ay = (aRow + 0.5) / 2. * 1.8 - 0.9;
  float avId = mod(vertexId, PER_AREA)-3.;

  vec4 a = area(avId, areaId);

  gl_Position = vec4(a.xy *- vec2(0.125, -0.4) + vec2(ax, ay), 0, 1);
  float snd = a.z;
  float hue = a.w;
  v_color = vec4(mix(hsv2rgb(vec3(hue, 2.-snd, snd)), vec3(snd *1.15,1,0.5), 0.0), 1.0);
  v_color = vec4(v_color.rgb * v_color.a, v_color.a);
}