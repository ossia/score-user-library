/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/97zwjZPbGFqPWiYZy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 48,
    "ORIGINAL_DATE": {
      "$date": 1543838624307
    }
  }
}*/

void main() {
  gl_PointSize = 10.0;

  vec2 xy = vec2(vertexId / 3.0, vertexId / 3.0);

  gl_Position = vec4(xy, 0.0, 1.0);

  v_color = vec4(1.0, 0.0, 0.0, 1.0);
}