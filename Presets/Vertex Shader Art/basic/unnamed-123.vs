/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "mklcp (ported from https://www.vertexshaderart.com/art/bi5qETD9A4okpa4oi)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 5000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 9,
    "ORIGINAL_DATE": {
      "$date": 1546352656458
    }
  }
}*/

void main(void)
{
  float sca = floor(sqrt(vertexCount));
  float x = mod(vertexId, sca)/(sca-1.);
  float y = floor(vertexId/sca)/(sca-1.);
  float af = 12.; // 20.
  float xf = sin(time + y*af)*0.2;
  float yf = sin(time + x*af)*0.2;
  vec2 xy = vec2(x+xf, y+yf)*2.-1.;

  gl_Position = vec4(xy*0.8,0,1);

  gl_PointSize = 1.;
  gl_PointSize += ((resolution.x)/sca)/5.;

  v_color = vec4(sin(x),sin(y),sin(time),0.);
}
// form: all