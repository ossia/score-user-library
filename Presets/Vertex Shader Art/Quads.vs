/*{
  "DESCRIPTION": "Quads",
  "CREDIT": "isa\u00edn (ported from https://www.vertexshaderart.com/art/F88Ekndwj4ihuRGmt)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 22,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1551482454133
    }
  }
}*/

void main() {

  float x = floor(vertexId / 2.0);
  float y = mod(vertexId + 1.0, 2.0);

  vec2 xy = vec2(x, y) * 0.1;

  gl_Position = vec4(xy, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
  gl_PointSize = 20.0;

}