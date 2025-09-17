/*{
  "DESCRIPTION": "color whip - : ^)",
  "CREDIT": "mol (ported from https://www.vertexshaderart.com/art/ef4RfHy9WFPvn43T6)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 64,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 209,
    "ORIGINAL_DATE": {
      "$date": 1543919593490
    }
  }
}*/

void main() {
  gl_PointSize = 5.0;

  v_color = vec4(

    abs(sin(vertexId * 0.1 - time * 8.0)),
    abs(sin(vertexId * 0.1 - time * 8.0 + 2.09)),
    abs(sin(vertexId * 0.1 - time * 8.0 + 4.18879020479)),
    1.0);

  gl_Position.x = sin(time * 2.0 - vertexId / 8.0) * vertexId / 64.0;
  gl_Position.y = cos(time * 2.0 - vertexId / 16.0) * vertexId / 64.0;
  gl_Position.z = 0.0;
  gl_Position[3] = 1.0;
}