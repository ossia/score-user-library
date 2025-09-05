/*{
  "DESCRIPTION": "lesson1",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/Gi7T5DRKnAnrvCAPp)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
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
    "ORIGINAL_VIEWS": 60,
    "ORIGINAL_DATE": {
      "$date": 1494422152151
    }
  }
}*/

void main () {
  gl_Position = vec4(0,0,0,1);
  gl_PointSize = 10.0;

  v_color = vec4(1,0,0,1);
}