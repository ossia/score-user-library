/*{
  "DESCRIPTION": " Gridding II - Hmmm!",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/BXfAoqsFbSNtWvJaQ)",
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1494975499602
    }
  }
}*/

// Taking control - the moving grid

void main() {
  float scale = 1.5;
  float modi = 0.5 * (sin(time)+1.);
  float grid = floor(modi * 50.) + 50.;
  float xoff = -0.5 * scale;
  float yoff = -0.5 * scale;
  float x = mod(vertexId , grid);
  float y = mod(floor(vertexId / grid), grid);
  float ux = x * scale / grid + xoff;
  float uy = y * scale / grid + yoff;
  gl_Position = vec4(ux, uy, 0, 1);
  gl_PointSize = 300./grid;
  v_color = vec4(1, 0, 0, 1);
}