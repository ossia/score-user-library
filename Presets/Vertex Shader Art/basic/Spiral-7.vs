/*{
  "DESCRIPTION": "Spiral",
  "CREDIT": "der (ported from https://www.vertexshaderart.com/art/trsmEtfPkaXKti9gH)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 15606,
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
    "ORIGINAL_VIEWS": 12,
    "ORIGINAL_DATE": {
      "$date": 1659650836575
    }
  }
}*/

float dist(vec2 p1, vec2 p2) {
  return sqrt(pow(p1.x - p2.x, 2.0) + pow(p1.y - p2.y, 2.0));
}

void main() {
  float across = floor(sqrt(vertexCount));

  float x = (mod(vertexId, across) / (across - 1.0) * 2.0 - 1.0) * 1.5;
  float y = (floor(vertexId / across) / (across - 1.0) * 2.0 - 1.0) * 1.5;

  float distFromCenter = dist(vec2(x, y), vec2(0.0, 0.0));
  float ang = atan(0.0 - y, 0.0 - x);

  float farthestDist = dist(vec2(1.0, 1.0), vec2(0.0, 0.0));

  float normX = cos(ang + time * (farthestDist - distFromCenter));
  float normY = sin(ang + time * (farthestDist - distFromCenter));

  float xPos = normX * distFromCenter;
  float yPos = normY * distFromCenter;

  gl_Position = vec4(xPos, yPos, 0.0, 1.0);

  gl_PointSize = 10.0;

  v_color = vec4(1.0, 1.0, 1.0, 1.0);
}