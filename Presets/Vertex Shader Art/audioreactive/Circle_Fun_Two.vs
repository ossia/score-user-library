/*{
  "DESCRIPTION": "Circle Fun Two",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/eGvHvcKj3nHkhw9C6)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 18619,
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
      "$date": 1496688133762
    }
  }
}*/

// Spiral Circle thingy

void main () {
  float v = vertexId;
  float vc = vertexCount * (1. + sin(time/2000.));
  //float sndFactor = texture(sound, vec2(;

  float spiral = 1. - 1.9 * v / (vc * vc);

  float grid = floor(vc / 1000.);
  float step100 = floor (100. * v / vc);
  float sndFactor = texture(sound, vec2(mod(step100, 4.), step100/400.)).r;
  float scale = 0.1 * (7. * sndFactor);

  float xoff = sndFactor * (sin(time/1.)/2.) * 0.5;
  float yoff = sndFactor * (sin(time/1.1)/2.) * 0.5;

  float y = sin(v / (50. * (2. + sin(time * 2000.)))) * spiral;
  float x = cos(v / (50. * (2. + sin(time * 2010.)))) * spiral;

  float ux = x * scale - xoff;
  float uy = y * scale - yoff;

  gl_Position = vec4(ux, uy, 0, 1);
  gl_PointSize = sndFactor * 5.;//v / (sndFactor *100000.) ;// grid;

  //v_color = vec4(sin(spiral), sin(time/1.1), sin(time), 1);
  //v_color = vec4(sin(spiral * 5. +time + sndFactor), 0.1, 0.5, 1);
  v_color = vec4(sndFactor * 2., sin(1./spiral), 1./spiral, 1);
}