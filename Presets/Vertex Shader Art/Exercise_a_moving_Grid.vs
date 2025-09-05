/*{
  "DESCRIPTION": "Exercise a moving Grid",
  "CREDIT": "minkicho (ported from https://www.vertexshaderart.com/art/f2btT6XFeFnaFopph)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 5000,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1684379404371
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

  vec2 xy = vec2(ux,vy)*1.3;
  gl_Position = vec4(xy,0,1);

  float soff = sin(time + x * y * 0.02) * 5.;

  gl_PointSize = 15.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(1,0,0,1);
}

