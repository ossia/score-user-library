/*{
  "DESCRIPTION": "Curves with powers - Making curves with powers",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/Tj6QZbDv6jioYkJtb)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 20000,
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
      "$date": 1529963938022
    }
  }
}*/


float lerp(float min, float max, float norm) {
  return (max - min) * norm + min;
}

void main() {
  float normal = (vertexId + 1.0) / vertexCount;
  float xExp = abs(mouse.x);
  float yExp = abs(mouse.y) * 2.0;

  float x = lerp(-1.0, 1.0, pow(normal, xExp)) - 0.5;
  float y = lerp(-1.0, 1.0, pow(normal, yExp));

  gl_Position = vec4(x * 0.5, y * 0.5, 0.0, 1.0);
  gl_PointSize = normal * 10.0 + 4.0;
  v_color = vec4(normal * normal * normal, 1.0, 1.0 - normal, 1);
}