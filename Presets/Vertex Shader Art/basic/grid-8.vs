/*{
  "DESCRIPTION": "grid",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/g5Ygw3eYNe7DzpA3a)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 1,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.15294117647058825,
    0.12941176470588237,
    0.43529411764705883,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 65,
    "ORIGINAL_DATE": {
      "$date": 1585498803324
    }
  }
}*/

void main() {
  float down= floor(sqrt(vertexCount));
  float across = floor(vertexCount/down);

  float x = mod(vertexId, across);
  float y = floor(vertexId /across);
  float u = x/(across-1.);
  float v = y/(across-1.);

  gl_Position = vec4(2.*u-1.,2.*v-1.,0,1);

  gl_PointSize = 10.0;
  gl_PointSize*=20./across;
  gl_PointSize*=resolution.x/600.;

  v_color = vec4(1,0,0,1);

}
