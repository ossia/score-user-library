/*{
  "DESCRIPTION": "Init - Hmmm!",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/zRecXKb9NuCfmnWv4)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0.6274509803921569,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1494969599667
    }
  }
}*/

void main() {
  gl_Position = vec4(0, 0, 0, 1);
  gl_PointSize = 40.;
  v_color = vec4(1, 0, 0, 1);
}