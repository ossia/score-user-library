/*{
  "DESCRIPTION": "Motion-1 - My First Motion Art",
  "CREDIT": "eren (ported from https://www.vertexshaderart.com/art/Hap5jDJiPwQZ9oJx6)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 6532,
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
    "ORIGINAL_VIEWS": 36,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1687691326508
    }
  }
}*/

void main(){

  float down = floor(sqrt(vertexCount));

  float zort = floor(vertexCount / down);

  float x = mod(vertexId, zort);

  float y = floor(vertexId / zort);

  float u = x / (zort - 1.);
  float v = y / (zort - 1.);

  float xoff = sin(time + y * 0.1) * 0.2;
  float yoff = sin(time + x * 0.1) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 0.5;

  gl_Position = vec4(xy, 0, 1);

  float soff = sin(time + x * y * 0.001) * 5.;

  gl_PointSize = 4.0 + soff;

  gl_PointSize *= 20. / zort;

  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(1, 0, 0, 1);

}
