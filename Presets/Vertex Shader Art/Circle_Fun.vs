/*{
  "DESCRIPTION": "Circle Fun",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/nw2X8ECBMqrgNbcQL)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 38360,
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
    "ORIGINAL_VIEWS": 78,
    "ORIGINAL_DATE": {
      "$date": 1496685376741
    }
  }
}*/

// Spiral Circle thingy
// Testing music sync

//paramater0 // general scale 0.1 to 0.5
//parameter1 // spiral stop 1.0 to 2.0
//parameter2 // color sensitivity
//parameter3 // sound sensitivity 5.0 to 10.
//arameter4 // point size 1.0 to 5.0

void main () {
  float v = vertexId * 200. * sin(time/20000.);
  //float sndFactor = texture(sound, vec2(;

  float spiral = 1. - 1.9 * vertexId / (vertexCount+vertexCount);

  float grid = floor(vertexCount / 1000.);
  float step100 = floor (100. * vertexId / vertexCount);
  float sndFactor = texture(sound, vec2(mod(step100, 4.), step100/400.)).r;
  float scale = 0.5 * (5. * sndFactor);

  float xoff = sndFactor * (sin(time/1.)/2.) * 0.5;
  float yoff = sndFactor * (sin(time/1.1)/2.) * 0.5;

  float y = sin(v / (50. * (2. + sin(time * 2000.)))) * spiral;
  float x = cos(v / (50. * (2. + sin(time * 2010.)))) * spiral;

  float ux = x * scale - xoff;
  float uy = y * scale - yoff;

  gl_Position = vec4(ux, uy, 0, 1);
  gl_PointSize = sndFactor * 3.;//v / (sndFactor *100000.) ;// grid;
  //v_color = vec4(sin(spiral), sin(time/1.1), sin(time), 1);
  //v_color = vec4(sin(spiral * 5. +time + sndFactor), 0.1, 0.5, 1);
  v_color = vec4(sndFactor * 2., sin(1./spiral), 1./spiral, 1);
}