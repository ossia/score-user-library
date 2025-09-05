/*{
  "DESCRIPTION": "z%%z",
  "CREDIT": "clydepashley (ported from https://www.vertexshaderart.com/art/us7EwfYeHRHwZoEsZ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 849,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1492808715355
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
  x = x / (across - 1.);
  y = y / (across - 1.);

  //Move back around origin
  x = x * 2. - 1.;
  y = y * 2. - 1.;

  float sin_thing = sin(vertexId + time);

  gl_Position = vec4(x,y,0,1);
  gl_PointSize = sin_thing * 10.;
  v_color = vec4(sin_thing * 140., sin_thing * 2.,mod(sin_thing,1.),1);
  //v_color = vec4(mod(sin_thing,2.), sin_thing * 2.,mod(sin_thing,1.),1);
}