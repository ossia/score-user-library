/*{
  "DESCRIPTION": "Tutorial-2",
  "CREDIT": "langtoner (ported from https://www.vertexshaderart.com/art/7GNBiei7nte4HfQN2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 10,
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
      "$date": 1598153676425
    }
  }
}*/

void main() {
 float x = vertexId /20.;
gl_Position = vec4(x,0,0,1);
gl_PointSize = 10.0;

  v_color = vec4(1,0,0,1);
}