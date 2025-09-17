/*{
  "DESCRIPTION": "bb22",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/8miH3KmYkczS5YbjP)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 38,
    "ORIGINAL_DATE": {
      "$date": 1591580089370
    }
  }
}*/

#define PI radians(180.0)
#define NUM_SEGMENTS 200.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0
//#define FIT_VERTICAL

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float numShapes = vertexCount / NUM_POINTS;
  float cv = count / numShapes;
  float offset = count * 0.02;
  float ev = point / NUM_SEGMENTS;
  float angle = ev * PI * 2.0 + offset * 0.1;
  float radius = 0.2;
  float c = cos(angle + time * 0.11) * radius;
  float s = sin(angle + time * 0.11) * radius;
  float orbitAngle = count * 0.01;

  float snd = texture(sound, vec2(ev * 0.1, cv * .1)).x;

  vec2 aspect = vec2(1, resolution.x / resolution.y) * 1.;

  float scale = pow(cv + 0.5, 2.7) + pow(snd, 5.0) * 3.;
  vec2 xy = vec2(
      c,
      s);
  gl_Position = vec4(xy * aspect * scale, 0, 1);

  float hue = cv * 0.2;
  float unf = step(0.8, snd);
  v_color = vec4(hsv2rgb(vec3(ev * 0.1 + 0.95, unf, unf + hue)), unf);
}