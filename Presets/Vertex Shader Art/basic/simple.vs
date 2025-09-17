/*{
  "DESCRIPTION": "simple - set to points",
  "CREDIT": "mol (ported from https://www.vertexshaderart.com/art/34z5eo3NAr7q87bLk)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 32,
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
    "ORIGINAL_VIEWS": 40,
    "ORIGINAL_DATE": {
      "$date": 1543916750725
    }
  }
}*/

void main() {
  gl_PointSize = 5.0;

  v_color = vec4(1.0, 1.0, 1.0, 1.0);

  gl_Position.x = sin(time + vertexId / 32.0) / 2.0;
  gl_Position.y = cos(time + vertexId / 32.0) / 2.0;
  gl_Position.z = 0.0;
  gl_Position[3] = 1.0;
}