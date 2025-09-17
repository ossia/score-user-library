/*{
  "DESCRIPTION": "Motion_sunwoo.lee",
  "CREDIT": "sunwoo.lee (ported from https://www.vertexshaderart.com/art/Qg6cjjRRKxsXEEGYB)",
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
    "ORIGINAL_VIEWS": 8,
    "ORIGINAL_DATE": {
      "$date": 1652894323783
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

  float xoff = sin(time + y);
  float yoff = sin(time + x);

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux,vy) * abs(sin(time))*0.7;

  gl_Position = vec4(xy,0,1);

  float amount = 5.0;
  float soff = sin(time + x * y * 0.02) * amount; //-5~5

  gl_PointSize = 7.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.0;

  // map to 0~1
  soff += amount;
  soff /= amount*2.0;

  // small = ash , big = flame
  v_color = vec4(soff,0,0,1);
}