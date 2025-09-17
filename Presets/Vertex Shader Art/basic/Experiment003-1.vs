/*{
  "DESCRIPTION": "Experiment003",
  "CREDIT": "thetuesday night machines (ported from https://www.vertexshaderart.com/art/zvyxJBkZ5mMZpXaLk)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 5000,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1546122101431
    }
  }
}*/


void main() {

  float x = atan(vertexId/100.-1.);
  float y = sin(time/4.+vertexId*4.)/2.;

  gl_Position = vec4(x-1., y-x+cos(time+vertexId), 0, 1);
  gl_PointSize = ((time*2.+vertexId-1.)*20.)+(cos(time*1.)*10.+20.);

  v_color = vec4(sin(time*2.+vertexId/.2),y+.3,.5,0.);
}