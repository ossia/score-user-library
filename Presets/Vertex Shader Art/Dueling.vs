/*{
  "DESCRIPTION": "Dueling",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/ALErfYvkmdWzuqg7M)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 1283,
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
    "ORIGINAL_VIEWS": 72,
    "ORIGINAL_DATE": {
      "$date": 1513129309697
    }
  }
}*/


void main() {

  float Pos = vertexId/vertexCount;

  gl_Position = vec4(Pos, 0, 0.5,0.5);

  v_color = vec4(1.0);
}