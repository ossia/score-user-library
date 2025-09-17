/*{
  "DESCRIPTION": "Lines",
  "CREDIT": "dertrackererpro (ported from https://www.vertexshaderart.com/art/j7geNJncnTGfxf9ZX)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 800,
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
    "ORIGINAL_VIEWS": 171,
    "ORIGINAL_DATE": {
      "$date": 1541187752601
    }
  }
}*/

void main () {
  vec3 pos = vec3(tan(vertexId), tan(time+vertexId), 0.0);

  gl_PointSize = 15.0;
  gl_Position = vec4(pos, 1.0);
  v_color = vec4(pos.x, pos.y, -pos.x, 1.0)+0.3;
}