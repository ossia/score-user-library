/*{
  "DESCRIPTION": "waves - My first vertex shader art",
  "CREDIT": "amagitakayosi (ported from https://www.vertexshaderart.com/art/RLCfXFKZw5SjhED9h)",
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
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 167,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1497589552952
    }
  }
}*/

void main() {
  float across = floor(sqrt(vertexCount));
  float x = mod(vertexId, across) / across;
  float y = floor(vertexId / across) / across;
  x = x* 3. - 1.5;
  y = y* 3. - 1.5;

  float u = x + sin(time * y) * .02;
  float v = y + cos(time * x) * 4.;

  gl_Position = vec4(u, v, 0, 1);
  gl_PointSize = 300. / across;

  v_color = vec4(0, 1, 1, 1);
}