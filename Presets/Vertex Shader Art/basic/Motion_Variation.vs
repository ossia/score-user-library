/*{
  "DESCRIPTION": "Motion Variation",
  "CREDIT": "minsu-kim-digipen (ported from https://www.vertexshaderart.com/art/aqszowTp3EkLRtdea)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 6405,
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
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1684411577463
    }
  }
}*/

// Name : Minsu Kim
// Assignment : Exercise - Vertexshaderart : Motion
// Course : CS250
// Spring 2023

// Make sure the layout is "LINES"!

void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = sin(time + y * 0.2) * 0.5;
  float yoff = sin(time + x * 0.1) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  gl_Position = vec4(xy, 0, 1);

  v_color = vec4(xoff * 3., y, x, 1);
}