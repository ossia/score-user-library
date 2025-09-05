/*{
  "DESCRIPTION": "Experiment003",
  "CREDIT": "thetuesday night machines (ported from https://www.vertexshaderart.com/art/YNrYu5vLMifYXQAyj)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    0.9333333333333333,
    0.7333333333333333,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 110,
    "ORIGINAL_DATE": {
      "$date": 1546126898429
    }
  }
}*/


void main() {

  float x = vertexId/15000.;
  float y = vertexId/20000. + atan(time/23.) + tan(vertexId/200.+time/40.)+0.5;

  gl_Position = vec4(x*2.2-1.3, y*1.-1., y, 1) * (sin(time/3.) +2.);
  gl_PointSize = vertexId/21. + 503. * (sin(time/5.)+1.);

  v_color = vec4(x,y/2.+0.5,1.,1.);
}