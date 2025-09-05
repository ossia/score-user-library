/*{
  "DESCRIPTION": "Circle of points",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/gxSjsgjmXdmzAwFJY)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 400,
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
    "ORIGINAL_VIEWS": 112,
    "ORIGINAL_DATE": {
      "$date": 1550248715719
    }
  }
}*/

const float speed = 0.2;

void main() {
  vec4 position =
    vec4(1.25 * abs(cos(time * speed) * -sin(time * speed)) * cos(speed * time + vertexId),
        vertexId/vertexCount*2.0-1.0,
        0.0, 1.0);
  gl_PointSize = vertexId/vertexCount * 5.0;
  gl_Position = position;
  v_color = vec4(1.0);
}