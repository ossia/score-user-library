/*{
  "DESCRIPTION": "Making A Grid",
  "CREDIT": "minsu-kim-digipen (ported from https://www.vertexshaderart.com/art/PJotDZ2XkNc3ut8ok)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.023529411764705882,
    0.16470588235294117,
    0.33725490196078434,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 9,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1684407025171
    }
  }
}*/

// Name : Minsu Kim
// Assignment : Exercise - Vertexshaderart : Making a Grid
// Course : CS250
// Spring 2023

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

  v_color = vec4(1, 0, 0, 1);
}