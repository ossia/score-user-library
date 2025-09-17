/*{
  "DESCRIPTION": "Motion with different motion pattern",
  "CREDIT": "seoseulbin (ported from https://www.vertexshaderart.com/art/SvKBPm8HSm9yzW4F2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Abstract"
  ],
  "POINT_COUNT": 6431,
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
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1684396760013
    }
  }
}*/

// Seulbin Seo
// Exercise Motion with different motion pattern
// CS250 Spring 2023

void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = cos(time + y * 0.2) * 0.2;
  float yoff = cos(time + y * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  gl_Position = vec4(xy, 0, 1);

  float soff = sin(time + x * y * 0.02) * 9.;

  gl_PointSize = 17.0 + soff;
  gl_PointSize *= 20. / (across);
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4 (1, sin(time), cos(time), 1);

}