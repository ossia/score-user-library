/*{
  "DESCRIPTION": "Making A Grid",
  "CREDIT": "donga.choi (ported from https://www.vertexshaderart.com/art/FAi4yHCJC2jr4B4Mj)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 10000,
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
    "ORIGINAL_VIEWS": 15,
    "ORIGINAL_DATE": {
      "$date": 1652877367926
    }
  }
}*/

//Dong-A Choi
//CS250
//Making A Grid exercise
//2022 spring

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across-1.);
  float v = y / (across-1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux,vy,0,1);
  gl_PointSize = 10.0;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(1,0,0,1);

}
