/*{
  "DESCRIPTION": "making A Grid donga.choi",
  "CREDIT": "donga.choi (ported from https://www.vertexshaderart.com/art/FufiW6ZAC4tzCrSqe)",
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
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 9,
    "ORIGINAL_DATE": {
      "$date": 1652878922531
    }
  }
}*/

//Dong-A Choi
//CS250
//Making A Grid exercise
//2022 spring

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across-1.);
  float v = y / (across-1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  float xPos = ux/2. + sin(time);

  gl_Position = vec4( xPos,vy/2. ,0,1);
  gl_PointSize = 10.0;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  if(xPos < 0.){
   v_color = vec4(1,0,mouse.x,1);
  }else {
     v_color = vec4(0,1,mouse.x,1);
  }

}
