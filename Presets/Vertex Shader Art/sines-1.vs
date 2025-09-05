/*{
  "DESCRIPTION": "sines",
  "CREDIT": "jason2 (ported from https://www.vertexshaderart.com/art/fKPK987qvE5gGHcWS)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 46119,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 312,
    "ORIGINAL_LIKES": 3,
    "ORIGINAL_DATE": {
      "$date": 1446790101440
    }
  }
}*/

#define PI 3.14159

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float traces = 6.0;
  float trace = mod(vertexId, traces);
  float x = -1.0 + 2.0 * vertexId / vertexCount;

  float speed = 1.0 * time;
  float amp = x * 0.7 * (sin(time) + (1.0 + trace) / traces);
  float y = amp * sin(speed + PI * x);

  gl_Position = vec4(x, y, 0, 1);
  float c = trace / traces;
  v_color = vec4(hsv2rgb(vec3(x, 0.5, 1)), 1);
}