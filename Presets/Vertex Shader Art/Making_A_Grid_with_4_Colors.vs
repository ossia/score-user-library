/*{
  "DESCRIPTION": "Making A Grid with 4 Colors",
  "CREDIT": "seoseulbin (ported from https://www.vertexshaderart.com/art/3NDzadNsSWytgiaLt)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 1690,
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
      "$date": 1684328885142
    }
  }
}*/

// Seulbin Seo
// Exercise Making A Grid with 4 Colors
// CS250 Spring 2022

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

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  if (u < 0.5 && v < 0.5) {
    v_color = vec4(0.85, 0.1, 0.57, 1);
  } else if (u >= 0.5 && v < 0.5) {
    v_color = vec4(0, 1, 0, 1);
  } else if (u < 0.5 && v >= 0.5) {
    v_color = vec4(0, 0.4, 1, 1);
  } else {
    v_color = vec4(1, 1.4, 0.2, 1);
  }
}