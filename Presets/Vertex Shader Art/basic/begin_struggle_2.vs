/*{
  "DESCRIPTION": "begin struggle 2 - Yes!",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/gZgDK3bN2z7xtma6A)",
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1494952775713
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

  float psize = mod(step, 3.) * 3. * (sin(time) + 1.);

  gl_Position = vec4(x * ux + xoff, y * uy + yoff, 0, 1);

  gl_PointSize = psize;

  v_color = vec4(1, 0, 0, 1);

}