/*{
  "DESCRIPTION": "Making a Grid - Moving Grid",
  "CREDIT": "minkicho (ported from https://www.vertexshaderart.com/art/q6CuGQiqZmHzrJ8N3)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 3233,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 25,
    "ORIGINAL_DATE": {
      "$date": 1683775508302
    }
  }
}*/


// Minki Cho
// Exercise Grid
// CS250 Spring 2022

void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float ux = u * 2.0 - 1.0;
  float vy = v * 2.0 - 1.0;

  float speed = 2.5;
  ux += sin(time * speed + u * 3. + vy * 0.5) * 0.06;
  vy += cos(time * speed + v * 3. + ux * 0.5) * 0.1;

  gl_Position = vec4(vy, ux, 0, 1);

  gl_PointSize = sin(time)*10.0;
  gl_PointSize *= resolution.x / 800.0;

  vec4 color1 = vec4(0.0, sin(time * 0.5) * 0.5 + 0.5, 0.0, 1.0);
  vec4 color2 = vec4(0.0, 0.0, cos(time * 1.5) * 0.5 + 0.5, 1.0);
  vec4 blendedColor = mix(color1, color2, (sin(time * 1.5) + 1.0) * 0.5);

  vec4 pointColor = vec4(ux, 1.0 - vy, 1., 1.0);
  v_color = mix(blendedColor, pointColor, 0.5);
}