/*{
  "DESCRIPTION": "Grid IV - Yes!",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/PyqCH2QLtx4JYsvAY)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1000,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1495005471663
    }
  }
}*/

void main() {

  float density = 50.;

  float xoff = -0.5 * sin(vertexId);

  float yoff = -0.5 * sin(time*vertexId);

  float ux = 0.01;

  float uy = 0.01;

  float x = mod(vertexId , density);

  float y = mod(floor(vertexId / density), density);

  gl_Position = vec4(x * ux + xoff, y * uy + yoff, 0, 1);

  gl_PointSize = 10.*(sin(time*vertexId/1000.)+ 1.); //mod(vertexId, density * density) / 5.;

  v_color = vec4(1, 0, 0, 1);

}