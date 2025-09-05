/*{
  "DESCRIPTION": "Simple and terrible first particle system - Terrible lol but its a start, not sure yet how to model life span per vertex just yet, even velocity / acceleration",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/EFDPXE3qAdfaPgMT3)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Abstract"
  ],
  "POINT_COUNT": 100,
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1524511390138
    }
  }
}*/

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float PI = 6.28;
  float p = vertexId / vertexCount;
  float life = mod(time, p * 10.0);
  float speed = mod(time, 2.0);
  float vx = cos(PI * p) * speed * life * 0.1;
  float vy = sin(PI * p) * speed * life * 0.1;

  gl_Position = vec4(vx, vy, 0.0, 1.0);
  gl_PointSize = 10.0;
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
}