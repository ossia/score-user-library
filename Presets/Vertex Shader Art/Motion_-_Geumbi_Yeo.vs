/*{
  "DESCRIPTION": "Motion - Geumbi Yeo",
  "CREDIT": "geumbi.yeo (ported from https://www.vertexshaderart.com/art/BTbTTkxMnk4AfcjGJ)",
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
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1684385537800
    }
  }
}*/

// Name : Geumbi Yeo
// Assignment : Exercise - VertexShaderart : Motion
// Course : CS250
// Term & Year : 2023 Spring

void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = sin(time + y * 0.2) * 0.1;
  float yoff = cos(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 5. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.5;

  gl_Position = vec4(xy, 0, 1);

  float soff = sin(time + x * y * 0.05) * 5.;

  gl_PointSize = abs(sin(time)) * 10.;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 400.;

  v_color = vec4(0.5, abs(cos(time)), sin(time), 1);
}