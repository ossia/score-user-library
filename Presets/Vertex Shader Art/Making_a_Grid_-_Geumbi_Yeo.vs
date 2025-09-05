/*{
  "DESCRIPTION": "Making a Grid - Geumbi Yeo ",
  "CREDIT": "geumbi.yeo (ported from https://www.vertexshaderart.com/art/LMN6w6vBdQz2DyQdB)",
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
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1684325107256
    }
  }
}*/

// Name : Geumbi Yeo
// Assignment : Exercise - Vertexshaderart : Making a Grid
// Course : CS250
// Term & Year : 2023 Spring

void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down );

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux, vy, 0,1);

  gl_PointSize = abs(cos(time)) * 10.;

  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(mouse.x, cos(time * 2.), mouse.y,1);
}