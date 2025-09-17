/*{
  "DESCRIPTION": "begin struggle 4 - Yes!",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/XszYFmoC9KohYbbBD)",
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
    "ORIGINAL_VIEWS": 8,
    "ORIGINAL_DATE": {
      "$date": 1494954037970
    }
  }
}*/

void main() {

  float density = 10.;

  float xoff = -0.5;

  float yoff = -0.5;

  float ux = 0.1;

  float uy = 0.1;

  float x = mod(vertexId , density);

  float y = mod(floor(vertexId / density), density);

  float step = mod(vertexId, density * density);

  float psize = 50.0 * sin(x) * sin(y) * (sin(time) + 2.);

  gl_Position = vec4(x * ux + xoff, y * uy + yoff, 0, 1);

  gl_PointSize = psize;

  v_color = vec4(y / 10. ,x / 10. , x + y / 20., 1);

}