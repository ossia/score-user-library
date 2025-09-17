/*{
  "DESCRIPTION": "Ksteamers",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/MTJf2S5uhN4Z4Fswj)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
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
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1496861625447
    }
  }
}*/

//Kstreamer

//KDrawmode=GL_POINTS

//KVerticesNumber=3860

// **** K Parameters **********
// **** parameter 0 is General Scale/Zoom
#define parameter0 1.0//KParameter0 1.0>>100.0
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
// **** parameter 6 is thumb tune
#define parameter6 2.0//KParameter6 1.0>>4.0
// **** parameter 6 is sound tune
#define parameter7 2.0//KParameter7 1.0>>4.0

void main () {
  float v = vertexId;

  float grid = floor(vertexCount / (1000.0 * (1.0 + sin(time/30.0))));
  float scale = parameter0 * 1.0 / (grid * grid);

  float xsound = 0.2 * parameter7; //range of values in sound
  float ysound = floor((v*240.0) / vertexCount) / 240.0;

  float sndFactor = texture(sound, vec2(xsound , ysound)).r;
  float sndFactorBass = texture(sound, vec2(0.1 * parameter6, 0.0)).r;

  float x = sin(sin(time/11.0)* v/100.0); //comod(v, grid);
  float y = cos(sin(time/10.0)* v/100.0); //mod(floor(v / grid), grid);

  float xoff = parameter2 / 2.0;
  float yoff = parameter3 / 2.0 + 0.1 * parameter1 * sndFactor;

  float xmod = (1.0 - (parameter4 * v / (vertexCount * 100.0)));
  xmod *= 10.0 * parameter1 * sndFactorBass;
  xmod *= sin(time/100.0);
  float ymod = (1.0 - (parameter5 * v / (vertexCount * 100.0)));
  ymod *= 10.0 * parameter1 * sndFactorBass;
  ymod *= sin(time/130.0);

  float ux = (x * xmod * scale - xoff);
  float uy = (y * ymod * scale - yoff);

  gl_Position = vec4(ux, uy, 0, 1);
  gl_PointSize = parameter1 * sndFactorBass * 40.0 * (vertexCount/(10.0*v+vertexCount));

  v_color = vec4(sin(sndFactor/2.0), v/vertexCount, v/vertexCount, 1);
}