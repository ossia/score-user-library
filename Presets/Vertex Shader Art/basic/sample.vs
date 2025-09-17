/*{
  "DESCRIPTION": "sample",
  "CREDIT": "sndmtk (ported from https://www.vertexshaderart.com/art/6eSja54pMxXcD9ArN)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.043137254901960784,
    0.043137254901960784,
    0.043137254901960784,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1501396470105
    }
  }
}*/

void main() {
  //点を正方形に並べた場合の１辺あたりの点の個数
  // 100 -> 10, 200->14.1423->14
  float down = floor(sqrt(vertexCount));
  // 1辺あたりの点の個数
  float across = floor(vertexCount / down);

  // 点nのx座標を 0 to (across-1) に割り当てる
  float x = mod(vertexId, across);
  // 点nのy座標を 0 to (across-1) に割り当てる
  float y = floor(vertexId / across);

  float xoff = sin(time + y * 0.2) * 0.3;
  float yoff = cos(time + x * 0.3) * 0.2;

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 0.8;

  gl_Position = vec4(xy, 0, 1);

  float soff = sin(time+x*y*0.6) * 10.;
  gl_PointSize = 10. + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(xoff, yoff, 0.3, 1);

}