/*{
  "DESCRIPTION": "Exercise - Vertexshaderart : Motion - https://www.vertexshaderart.com/art/q6CuGQiqZmHzrJ8N3",
  "CREDIT": "minkicho (ported from https://www.vertexshaderart.com/art/p2AWNesbs8S8c9WaR)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Abstract"
  ],
  "POINT_COUNT": 20784,
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
    "ORIGINAL_VIEWS": 15,
    "ORIGINAL_DATE": {
      "$date": 1683777765847
    }
  }
}*/

// Minki Cho
// Exercise a moving Grid
// CS250 Spring 2022

//
void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount/down);

  float x = mod(vertexId, across);
  float y = floor(vertexId/across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = sin(time + y * 0.1) * 0.1;
  float yoff = sin(time + y * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + xoff;

  gl_Position = vec4(ux, vy, 0., 1.);

  gl_PointSize = 10.0;
  gl_PointSize *= 20./across;
  gl_PointSize *= resolution.x / 600.;

  vec4 color1 = vec4(1.0, sin(time * 0.5) * 0.5 + 0.5, 0.0, 1.0);
  vec4 color2 = vec4(0.0, 0.0, cos(time * 0.5) * 0.5 + 0.5, 1.0);
  vec4 blendedColor = mix(color1, color2, (sin(time * 0.5) + 1.0) * 0.5);

  vec4 pointColor = vec4(ux, 1.0 - vy, 1., 1.0);
  v_color = mix(pointColor, blendedColor, 0.5);
}

