/*{
  "DESCRIPTION": "training step 1.1",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/7W6jf6wm4is8A9o9z)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.2,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 9,
    "ORIGINAL_DATE": {
      "$date": 1494948627525
    }
  }
}*/

void main() {
  gl_Position = vec4(1, 0, 0, 1);
  gl_PointSize = 40.;
  v_color = vec4(1, 0, 0, 1);
}