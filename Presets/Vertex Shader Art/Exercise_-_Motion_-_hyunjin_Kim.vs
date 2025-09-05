/*{
  "DESCRIPTION": "Exercise - Motion - hyunjin Kim",
  "CREDIT": "hyunjin-kim-dp (ported from https://www.vertexshaderart.com/art/Jy4jz9wJ54XyG6hFF)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1003,
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
    "ORIGINAL_VIEWS": 8,
    "ORIGINAL_DATE": {
      "$date": 1652949103477
    }
  }
}*/

// hyunjin Kim
// cs250 exercise - Motion
// spring 2022

void main() {
  float down = sqrt(vertexCount);
  float across = floor(vertexCount / down);
  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = floor(x) / (across - 1.);
  float v = floor(y) / (across - 1.);

  float xoff = sin(time + floor(y) * 0.01);
  float yoff = cos(time + floor(x) * 0.01);

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 0.5;

  gl_Position = vec4(xy, 0, 1);

  float soff = sin(time * u * v) * 10.;
  gl_PointSize = 15.0 + soff;
  gl_PointSize *= 20.0 / across;
  //gl_PointSize *= resolution.x / 600.0;
  v_color = vec4(v, v, v + 0.2, 1);
}