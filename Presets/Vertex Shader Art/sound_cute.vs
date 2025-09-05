/*{
  "DESCRIPTION": "sound cute",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/Z3SAeG8oMryJKuF8z)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 26331,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1496679900142
    }
  }
}*/

void main() {
float vc = vertexCount * (1. + sin(time / 2.)) / 4.;
  float density = floor(vc / 100.) + 1.;

  //float xoff = -0.5* (density / 20.);
  //float yoff = -0.5 * (density / 20.);

  float xoff = -1. * (1. / density * density);
  float yoff = -1. * (1. / density * density);
  float ux = 0.1 * (20. / density);
  float uy = 0.1 * (20. / density);
  float x = mod(vertexId , density);
  float y = mod(floor(vertexId / density), density);
  float sndF = texture(sound, vec2(x * 5. / density, y / (density * 2.))).r;
  //gl_Position = vec4(x * ux + xoff, y * uy + yoff, 0, 1);
  gl_Position = vec4(y * uy + yoff, x * ux + xoff, 0, 1);
  //gl_PointSize = mod(vertexId, density * density) / 5.;
  gl_PointSize = (200. / density) * sndF * 5.;
  v_color = vec4(1, 0, 0, 1);
}