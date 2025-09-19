/*{
  "DESCRIPTION": "Making a Grid",
  "CREDIT": "geonhwisim-digipen (ported from https://www.vertexshaderart.com/art/iQGt7fDGEeR4vD6ez)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.8745098039215686,
    0.5843137254901961,
    0.7098039215686275,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1652946877995
    }
  }
}*/

// Name: Geonhwi Sim
// Assignment Name: Making a grid
// Course Name: CS250
// Term: Spring 2022

void main() {
  float down = sqrt(vertexCount);
  float across = floor(vertexCount / down);
  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1. * sin(time * 0.5);
  float vy = v * 2. - 1. * cos(time * 0.5);

  gl_Position = vec4(ux - 1.0, vy - 1.0, 0, 1);
  gl_PointSize = 15.0;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 400.0;

  v_color = vec4(0, 0, 0, 1);
}