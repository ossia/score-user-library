/*{
  "DESCRIPTION": "Getting it - Yes!",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/ZvcLBFp3AkteTsGku)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
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
    "ORIGINAL_VIEWS": 12,
    "ORIGINAL_DATE": {
      "$date": 1494927741274
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

  gl_Position = vec4(x * ux, y * uy, 0, 1);

  gl_PointSize = mod(vertexId, density * density) / 5.;

  v_color = vec4(1, 0, 0, 1);

}