/*{
  "DESCRIPTION": "Making A Grid - tweaks",
  "CREDIT": "seongryul.park (ported from https://www.vertexshaderart.com/art/583kqaAomZpfinWXk)",
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1684334697139
    }
  }
}*/

// seongryul.park
// CS250 spring 2023
// Making A Grid

void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. * sin(time);
  float vy = v * 2. * cos(time);

  gl_Position = vec4(ux, vy, 0, 1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.;

  float r = sin(time * 2.);
  float g = sin(time * 3.);
  float b = sin(time * 4.);

  v_color = vec4(r, g, b, 1);
}