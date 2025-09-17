/*{
  "DESCRIPTION": "ring",
  "CREDIT": "danyalillo (ported from https://www.vertexshaderart.com/art/K3dPqehYPJMnZyDBD)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 889,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1551500835305
    }
  }
}*/

void main() {
  float width = 20.0;

  float x = floor(vertexId / 2.0);
  float y = mod(vertexId + 1.0, 2.0);

  float squares = 36.0;
  float angle = (x / squares) * radians(360.0);
  float radius = y + 1.0;

  float ux = radius * cos(angle) + 35.0;
  float vy = radius * sin(angle);
  if(vertexId > 74.0)
  {
    float test = mod(vertexId, 75.0);
    if(test != 0.0)
    {
     ux = ux - floor(vertexId / 74.0) * 4.0;
    }
  }

  vec2 xy = vec2(ux, vy) * 0.1;

  gl_Position = vec4(xy, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
  gl_PointSize = 10.0;
}