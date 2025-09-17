/*{
  "DESCRIPTION": "tutorial-1-0 initial grid",
  "CREDIT": "eugene (ported from https://www.vertexshaderart.com/art/6d4uyMnEKnip4oyLR)",
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
    0.06666666666666667,
    0.25882352941176473,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1605218789392
    }
  }
}*/

void main() {

  float across = 31.;

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux, vy, 0, 1);
  gl_PointSize = 10.0;
  v_color = vec4(1, 0, 0, 1);

}