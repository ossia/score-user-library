/*{
  "DESCRIPTION": "tuto 1",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/kyrjHeuSM5skDfpNo)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 837,
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
    "ORIGINAL_VIEWS": 111,
    "ORIGINAL_DATE": {
      "$date": 1501775778514
    }
  }
}*/

void main() {
 // float a = vertexId /20.;
  float x = mod(vertexId, 10.);
  float y = floor(vertexId /10.);
  float u = x/10.;
  float v = y/10.;
  float ucorr = (u*2.)-1.;
  float vcorr = (v*2.)-1.;

  gl_Position = vec4(ucorr, vcorr, 0, 1);
  gl_PointSize = 10.;
  v_color = vec4(1, 0, 0, 1);

}
