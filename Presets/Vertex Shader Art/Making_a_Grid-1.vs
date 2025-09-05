/*{
  "DESCRIPTION": "Making a Grid",
  "CREDIT": "sunwoo.lee (ported from https://www.vertexshaderart.com/art/Kx8LRqN4KEH3xcg9Q)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.27058823529411763,
    0.23921568627450981,
    0.6823529411764706,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 11,
    "ORIGINAL_DATE": {
      "$date": 1652633125863
    }
  }
}*/

// // Name: sunwoo.lee
// // Assignment name: Making a Grid
// // Course name: CS250
// // Term: 2022 Spring

void main()
{
  float down = floor(sqrt(vertexCount));

  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux,vy,0,1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.0;

  v_color = vec4(1,0,0,1);
}