/*{
  "DESCRIPTION": "Spiral (old)",
  "CREDIT": "der (ported from https://www.vertexshaderart.com/art/KRpCEmbJ2GTTRtxsR)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 10404,
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
    "ORIGINAL_VIEWS": 9,
    "ORIGINAL_DATE": {
      "$date": 1659646335005
    }
  }
}*/

float dist(vec2 p1, vec2 p2) {
  return sqrt(pow(p1.x - p2.x, 2.0) + pow(p1.y - p2.y, 2.0));
}

void main() {
  float across = floor(sqrt(vertexCount));

  float x = ((mod(vertexId, across) / (across - 1.0)) * 2.0 - 1.0);
  float y =((floor(vertexId / across) / (across - 1.0)) * 2.0 - 1.0);

  float distFromCenter = dist(vec2(x, y), vec2(0.0, 0.0));

  if(1.0 - distFromCenter < 0.0) {
    return;
  }

  float ang = atan(0.0 - y, 0.0 - x);

  float normX = cos(ang + time * (1.0 - distFromCenter));
  float normY = sin(ang + time * (1.0 - distFromCenter));

  float xPos = normX * distFromCenter;
  float yPos = normY * distFromCenter;

  float aspect = resolution.y / resolution.x;

  gl_Position = vec4(xPos * aspect, yPos, 0.0, 1.0);

  gl_PointSize = 10.0;

  v_color = vec4(1.0, 1.0, 1.0, 1.0);
}