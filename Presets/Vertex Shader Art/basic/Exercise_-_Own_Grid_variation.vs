/*{
  "DESCRIPTION": "Exercise - Own Grid variation - Exercise - Own Grid variation",
  "CREDIT": "byungchan.park (ported from https://www.vertexshaderart.com/art/8Typ5eK6bCd5ziWFf)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 624,
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
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1684316117961
    }
  }
}*/

//name : Byungchan Park
//assignment : Exercise - Vertexshaderart : Making a Grid, own variation
//course name : CS250
//term : Spring 2023

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount/down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux * cos(time/4.) ,vy * cos(time), 0,1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(1, 0, 0, 1);
  v_color += vec4(ux * cos(time),vy * cos(time * 2.), u * cos(time * 3.),1);

}