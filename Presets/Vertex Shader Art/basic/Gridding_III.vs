/*{
  "DESCRIPTION": " Gridding III - Hmmm!",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/QRwggT8zdiZbYuaXv)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 10000,
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
      "$date": 1494976485126
    }
  }
}*/

// Taking control - the moving grid

void main() {
  float scale = 2.;
  float modi = 0.5 * (sin(time)+1.);
  float lfo1 = (sin(time * 1.1) + 1.) / 2.;
  float lfo2 = (cos(time * 1.5) + 1.) / 2.;
  float grid = floor(modi * 10.) + 10.;
  float xoff = -0.5 * scale;
  float yoff = -0.5 * scale;
  float x = mod(vertexId , grid);
  float y = mod(floor(vertexId / grid), grid);
  float ux = x * lfo1 * scale / grid + xoff * lfo2;
  float uy = y * scale * lfo2 / grid + yoff * lfo1;
  gl_Position = vec4(ux, uy, 0, 1);
  gl_PointSize = 100./grid;
  v_color = vec4(1, 0, 0, 1);
}