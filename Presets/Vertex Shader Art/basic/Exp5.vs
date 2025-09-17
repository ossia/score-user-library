/*{
  "DESCRIPTION": "Exp5",
  "CREDIT": "thetuesday night machines (ported from https://www.vertexshaderart.com/art/LhgDszKTstGZBHjt7)",
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
    0.7333333333333333,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 110,
    "ORIGINAL_DATE": {
      "$date": 1546350610823
    }
  }
}*/

void main() {

  float x = vertexId/100. + sin(time/41.) ;
  float y = sin(time/17. + tan(vertexId/600.));

  gl_Position = vec4(x-4.-sin(time/20.), -y*(cos(x+vertexId)+0.), sin(x), 1.);

  gl_PointSize = 10. + (sin(time/12.+vertexId*50.)/2.+.5)*90.;

  v_color = vec4(tan(x), y, cos(time/7.)/2.+.8, 1.);
}