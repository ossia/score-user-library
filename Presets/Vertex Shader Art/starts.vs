/*{
  "DESCRIPTION": "starts",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/bpN3ufoDGdkJjxFsQ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Nature",
    "Abstract"
  ],
  "POINT_COUNT": 3000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1601,
    "ORIGINAL_LIKES": 7,
    "ORIGINAL_DATE": {
      "$date": 1445863358973
    }
  }
}*/

#define PI 3.14159
// triangles per thing we want to draw
#define NUM_TRIANGLES 2.0
// points pre thing
#define NUM_POINTS (NUM_TRIANGLES * 3.0)
#define STEP 2.0
//#define FIT_VERTICAL

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  gl_PointSize = 30.0;
  float localTime = time;
  // pointId: 0, 1, 2, for each point in thing
  float pointId = mod(vertexId, NUM_POINTS);
  // each triangle 0,1,2,0,1,2 ...
  float triPointId = mod(vertexId, 3.0);
  // thingId: counts things
  float thingId = floor(vertexId / NUM_POINTS);
  // triId: 0, 1, .. for each triangle in thing
  float triId = mod(floor(pointId / 3.0), NUM_TRIANGLES);
  float angle = (triId * 0.5 + triPointId) * PI * 2.0 / 3.0;

  float baseAngle = pow(thingId * 0.9, 0.8) + thingId * 0.01;

  float u = fract(thingId * 0.001) * 0.2 + 0.01;
  float v = mod(thingId * 0.01, 0.25) * 0.05;
  float snd = texture(sound, vec2(u, v)).r;

  float radius = pow(thingId * 0.002, 1.00) * 0.1 + pow(snd, 4.0) * 0.2;
  float c = cos(angle) * radius;
  float s = sin(angle) * radius;

  float orbitAngle = baseAngle + snd * 0.0;
  float innerRadius = pow(thingId * 0.0025, 1.2) + pow(snd, 4.0);
  float oC = cos(orbitAngle + thingId * 0.01) * innerRadius;
  float oS = sin(orbitAngle + thingId * 0.01) * innerRadius;

  #ifdef FIT_VERTICAL
    vec2 aspect = vec2(resolution.y / resolution.x, 1);
  #else
    vec2 aspect = vec2(1, resolution.x / resolution.y);
  #endif

  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect + mouse * 0.1, 0, 1);

  float hue = (1.0 - fract(0.0 + thingId * 0.001 + sin(time) * 0.5)) * 0.2;
  float sat = 1.0;
  float val = 0.2 + pow(snd, 4.0);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}