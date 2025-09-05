/*{
  "DESCRIPTION": " Gridding - Hmmm!",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/h8Ao3xWvFcr2BjkPn)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1494975113775
    }
  }
}*/

// Taking control - the moving grid

void main() {
  float scale = 1.;
  float modi = 1.; //0.5 * (sin(time)+1.);
  float grid = floor(modi * 5.) + 5.;
  float xoff = -0.5 * scale;
  float yoff = -0.5 * scale;
  float x = mod(vertexId , grid);
  float y = mod(floor(vertexId / grid), grid);
  float ux = x * scale / grid + xoff;
  float uy = y * scale / grid + yoff;
  gl_Position = vec4(ux, uy, 0, 1);
  gl_PointSize = 100./grid;
  v_color = vec4(1, 0, 0, 1);
}