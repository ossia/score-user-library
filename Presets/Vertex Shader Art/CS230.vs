/*{
  "DESCRIPTION": "CS230 - Eunjin Hong 2019",
  "CREDIT": "_ (ported from https://www.vertexshaderart.com/art/4erk8kqXtJp9XeGP8)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_DATE": {
      "$date": 1554207492050
    }
  }
}*/

/*------------------------------------------------------------------------
Author : Eunjin Hong
Assignment Name/Number : Shader/3 (Extra Credit)
Course Name : CS230
Term : Spring 2019
------------------------------------------------------------------------*/

//Don't know the reason why but the music doesn't work very often...

void main() {

  float snd = texture(sound, vec2(mouse.x)).r;
  float x = mod(vertexId, 10.);

  gl_Position = vec4(snd*mouse.x*x, 0, 0, 1);
  gl_PointSize = abs(sin(time))*snd*50.+20.;

  v_color = vec4(abs(sin(snd)),abs(cos(snd)),abs(tan(snd)),1.0);

}