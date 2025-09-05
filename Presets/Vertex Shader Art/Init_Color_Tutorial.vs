/*{
  "DESCRIPTION": "Init Color Tutorial",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/HCYetf4hAQidqDBdG)",
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
    0.25098039215686274,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 9,
    "ORIGINAL_DATE": {
      "$date": 1495062143932
    }
  }
}*/

// a good example to start adding Kparameters

void main() {
  float down = sqrt(vertexCount);
  float across = floor(vertexCount / down);
  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = sin(time + y * 0.2) * 0.1;
  float yoff = sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  gl_Position = vec4(xy, 0, 1);

  //float soff = sin(time + x * y ) * 500.;
  float soff = (sin(time + x / (y+2.)) + sin(time + y / (x+3.))) * 50.;

  gl_PointSize = soff/(xoff+ yoff +50.) +10. ;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;
  v_color = vec4(soff/100., xoff*10., sin(soff/10.) +1., 0);
  // v_color = vec4(1, 1, 1, 1);
}