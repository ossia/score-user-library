/*{
  "DESCRIPTION": "Making A Grid with Colors",
  "CREDIT": "juhong.mo (ported from https://www.vertexshaderart.com/art/HigFydDgNaipM7SBk)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 1050,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1652973267011
    }
  }
}*/

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 0.2;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = 10.0;
  gl_PointSize *= 200. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(0.7 , 0, 1, 1) + vec4(ux*ux, 1.0-vy, u*u*2.0, 1);
}