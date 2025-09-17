/*{
  "DESCRIPTION": "begin struggle 3 - Yes!",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/rRHoXfKZBnnwFz4bZ)",
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1494953258069
    }
  }
}*/

void main() {

  float density = 10.;

  float xoff = -1.;

  float yoff = -1.;

  float ux = 0.2;

  float uy = 0.2;

  float x = mod(vertexId , density);

  float y = mod(floor(vertexId / density), density);

  float step = mod(vertexId, density * density);

  float psize = mod(step, 3.) * 3. * (sin(time) + 1.);

  gl_Position = vec4(x * ux + xoff, y * uy + yoff, 0, 1);

  gl_PointSize = psize;

  v_color = vec4(y * 100.,x * 100., time, 1);

}