/*{
  "DESCRIPTION": "Making a grid",
  "CREDIT": "daehyeon.kim (ported from https://www.vertexshaderart.com/art/gQ93FbmuckckWhhix)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 20000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.15294117647058825,
    0.14901960784313725,
    0.34901960784313724,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 10,
    "ORIGINAL_DATE": {
      "$date": 1652873628837
    }
  }
}*/

//Daehyeon Kim
//Make a grid
//CS250
//Spring, 2022

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(1,0,0,1);
}