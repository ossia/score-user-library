/*{
  "DESCRIPTION": "wip3",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/K9kkXT25juoLDcni4)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 9680,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 3908,
    "ORIGINAL_DATE": {
      "$date": 1446199318665
    }
  }
}*/

#define PI 3.14159
#define ACROSS 10.
#define DOWN 10.
#define PER_AREA ((ACROSS + 1.) * (DOWN + 1.) * 10.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 area(float vertexId, float areaId) {
  // 0, 2, 2, 4, 4, 1, 3, 3, 0
  float pointId = mod((floor(vertexId / 2.) + mod(vertexId, 2.)) * 2., 5.);
  float thingId = floor(vertexId / 10.);
  float col = mod(thingId, ACROSS + 1.);
  float row = floor(thingId / (ACROSS + 1.));
  float u = col / ACROSS;
  float v = row / DOWN;
  float x = u * 2. - 1.;
  float y = v * 2. - 1.;

  float d = length(vec2(x, y));
  float su = mod(PI * 2. + atan(y ,x) + areaId / .8 * PI * 2. + time, PI * 2.) / (PI * 2.);
  float sv = d * 0.1;
  float snd = texture(sound, vec2(su * 0.25 / 8. * areaId, sv)).r;

  float r = 0.04 + pow(snd, 3.) * 0.15;
  float a = pointId / 5. * PI * 2. + thingId * 0.05 + time * 2.;
  vec2 cs = vec2(cos(a), sin(a));
  vec2 xy = cs * r;
  vec2 aspect = vec2(1, resolution.x / resolution.y);

  float hue = (time * 0.01) + areaId / 8.;

  return vec4(
    vec2(x, y) * 1.0 + xy * aspect,
    snd,
    hue);
}

void main() {
  gl_PointSize = 4.0;

  float areaId = floor(vertexId / PER_AREA);
  float aCol = mod(areaId, 4.);
  float aRow = floor(areaId / 4.);
  float ax = (aCol + 0.5) / 4. * 2. - 1.;
  float ay = (aRow + 0.5) / 2. * 1.8 - 0.9;
  float avId = mod(vertexId, PER_AREA);

  vec4 a = area(avId, areaId);

  gl_Position = vec4(a.xy * vec2(0.25, 0.4) + vec2(ax, ay), 0, 1);
  float snd = a.z;
  float hue = a.w;
  v_color = vec4(mix(hsv2rgb(vec3(hue, 1, snd)), vec3(1,1,1), 0.0), 1.0);
  v_color = vec4(v_color.rgb * v_color.a, v_color.a);
}