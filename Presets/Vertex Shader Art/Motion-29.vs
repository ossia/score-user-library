/*{
  "DESCRIPTION": "Motion",
  "CREDIT": "sunwoo.lee (ported from https://www.vertexshaderart.com/art/q5ixDP7gFemPmYGSG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1000,
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
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1652885975231
    }
  }
}*/

// // Name: sunwoo.lee
// // Assignment name: Motion
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

  float xoff = sin(time + y * 0.2) * 0.1;
  float yoff = sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux,vy) * 1.3;

  gl_Position = vec4(xy,0,1);

  float soff = sin(time + x * y * 0.02) * 5.0;

  gl_PointSize = 15.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.0;

  v_color = vec4(1,0,0,1);
}