/*{
  "DESCRIPTION": "init sound",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/8rEyCeYdp5FF6AwKL)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Particles"
  ],
  "POINT_COUNT": 3860,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1496781508805
    }
  }
}*/

// Init file

//KDrawmode=GL_POINTS

//KVerticesNumber=3860

// **** K Parameters **********
// **** parameter 0 is General Scale/Zoom
#define parameter0 200.0//KParameter0 1.0>>100.0
// **** parameter 1 is Sound Sensitivity
#define parameter1 5.0//KParameter1 1.0>>2.0
// **** parameter 2 is x offset mod
#define parameter2 0.3//KParameter2 1.0>>2.0
// **** parameter 3 is y offset mod
#define parameter3 0.3//KParameter3 1.0>>2.0
// **** parameter 4 is x mod factor
#define parameter4 100.0//KParameter4 10.0>>100.0
// **** parameter 5 is y mod factor
#define parameter5 100.0//KParameter5 10.0>>100.0

void main () {
  float v = vertexId;

  float grid = floor(vertexCount / 10.0);
  float scale = parameter0 * 2.0 / (grid);

  float x = sin(v/100.0); //comod(v, grid);
  float y = cos(v/100.0); //mod(floor(v / grid), grid);

  float xoff = parameter2 / 2.0;
  float yoff = parameter3 / 2.0;

  float xsound = 0.3; //range of values in sound
  float ysound = floor((v*240.0) / vertexCount) / 240.0;

  float sndFactor = texture(sound, vec2(xsound , ysound)).r;

  float xmod = (1.0 - (parameter4 * v / (vertexCount * 100.0)));
  float ymod = (1.0 - (parameter5 * v / (vertexCount * 100.0)));

  float ux = (x * xmod * scale - xoff);
  float uy = (y * ymod * scale - yoff);

  gl_Position = vec4(ux, uy, 0, 1);
  gl_PointSize = sndFactor * 10.0;

  v_color = vec4(1, 0, 0, 1);
}