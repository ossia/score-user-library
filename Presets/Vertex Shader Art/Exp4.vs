/*{
  "DESCRIPTION": "Exp4",
  "CREDIT": "thetuesday night machines (ported from https://www.vertexshaderart.com/art/Dzq7Xbo9hsf8fwr58)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 40100,
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
    "ORIGINAL_VIEWS": 132,
    "ORIGINAL_DATE": {
      "$date": 1546168517524
    }
  }
}*/

void main() {

  float x = vertexId/130. + sin(time/41.) ;
  float y = sin(time/17. + tan(vertexId));

  gl_Position = vec4(x-2.-sin(time/20.), -y*(cos(x+vertexId)+0.5), 0., 1.);

  gl_PointSize = 10. + (sin(time/12.+vertexId*5.)/2.+.5)*9.;

  v_color = vec4(sin(x)/2., y/2.+.2, cos(time/7.)/2.+.8, 1.);
}