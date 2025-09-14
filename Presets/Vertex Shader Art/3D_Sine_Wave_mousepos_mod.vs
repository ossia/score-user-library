/*{
  "DESCRIPTION": "3D Sine Wave_mousepos mod - change color by mouseposition",
  "CREDIT": "patrik (ported from https://www.vertexshaderart.com/art/GPneC8Rz7k8CDKL6i)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 50000,
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1540987667959
    }
  }
}*/

void main () {
  vec4 pos = vec4(-1.0, sin(4.0*time + vertexId * 0.005)-0.5 * 0.8, 0.0, 1.0);
  gl_PointSize = 15.0;
  gl_Position = pos + vertexId*0.0006;
  v_color = vec4(mouse, pos.y, 1.0) + 0.5;
}