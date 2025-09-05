/*{
  "DESCRIPTION": "test",
  "CREDIT": "ltms (ported from https://www.vertexshaderart.com/art/PJNdD52L3irdZzLDv)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 346,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.00392156862745098,
    0,
    0.23921568627450981,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1608273901146
    }
  }
}*/

void main() {
  //
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  // igy csak a x,y > 0 tartomanyban lesznek pontok (jobb felso)
  // -1 azert kell, mert 0-9-ig megy x es y, 10zel osztva sose lesz 1 (emiatt nem volt jobb oldalt pontok)
  float u = x / (across-1.);
  float v = y / (across-1.);

  // megvaltoztatom az ertektartomanyt -1, +1 -re
  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux,vy,0,1);
  gl_PointSize = 10.;
  // valtoztatjuk a pontok meretet attol fuggoen hany vertexunk van
  gl_PointSize *= 20. / across;
  // valtoztatjuk a pontok meretet a felbontastol fuggoen, hogy mindig arányos maradjon
  gl_PointSize *= resolution.x / 600.;

  v_color= vec4(1,0,0,1);
}