/*{
  "DESCRIPTION": "z%%z 4 music",
  "CREDIT": "clydepashley (ported from https://www.vertexshaderart.com/art/C9riFtXRKgMEZyY7p)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 20,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1492813335580
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

  float snd = texture(sound, vec2(u, 0.)).r;
  float sin_thing = sin(vertexId + snd);
  //Sin

  x = sin(x+(snd/6.)/y);
  //y = cos(x+(snd/1000.)/y/(snd/1000.));

  //Comment and uncomment here, and change vertexCount to 10, 20, 50, 5000
  //y = cos(x+(snd/10.))*3.5 - 2.9;
  //y = cos(y+(snd/10.))*3.5 - 2.9;

  gl_Position = vec4(x,y,0,1);
  gl_PointSize = sin_thing * 10.;
  //v_color = vec4(snd * 4., sin_thing * 20.,mod(snd,1.),1);
  //v_color = vec4(snd+snd, mod(snd, 0.5) , mod(snd,1.3),1);
  v_color = vec4(mod(sin_thing,2.), sin_thing * 2.,mod(sin_thing,1.),1);
  //v_color = vec4(snd * snd, sin_thing * 20.,mod(snd,1.),1);
}