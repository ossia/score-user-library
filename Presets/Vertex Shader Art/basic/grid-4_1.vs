/*{
  "DESCRIPTION": "grid",
  "CREDIT": "soumakdev (ported from https://www.vertexshaderart.com/art/Kq2X2rn957ZFHdph9)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 4137,
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
      "$date": 1625681930753
    }
  }
}*/

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = 0.5 - x / (across -1.);
  float v = 0.5 - y / (across - 1.);

  gl_Position = vec4(u,v,0,1);

  gl_PointSize = 10.;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x /600.;

  v_color = vec4(1, 0, 0,1);
}