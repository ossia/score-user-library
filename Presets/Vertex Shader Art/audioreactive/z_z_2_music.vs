/*{
  "DESCRIPTION": "z%%z 2 music",
  "CREDIT": "clydepashley (ported from https://www.vertexshaderart.com/art/2djzoxSxpM9HnRXQH)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 5912,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1492809664637
    }
  }
}*/

void main() {

  float down = floor(sqrt (vertexCount));
  float across = floor (vertexCount / down);

  //Create Grid
  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  //Respace out
  float u = x / (across - 1.);
  float v = y / (across - 1.);
  x = u;
  y = v;

  //Move back around origin
  x = x * 2. - 1.;
  y = y * 2. - 1.;

  //Sin
  x = sin(x/y);
  y = sin(x/y);

  float sin_thing = sin(vertexId + time);
  float snd = texture(sound, vec2(u, 0.)).r;

  gl_Position = vec4(x,y,0,1);
  gl_PointSize = sin_thing * 10.;
  v_color = vec4(snd * 4., sin_thing * 20.,mod(snd,1.),1);
  //v_color = vec4(mod(sin_thing,2.), sin_thing * 2.,mod(sin_thing,1.),1);
}