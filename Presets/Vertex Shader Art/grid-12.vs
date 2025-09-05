/*{
  "DESCRIPTION": "grid",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/wJuenftt4G6XBy8x7)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 15238,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 70,
    "ORIGINAL_DATE": {
      "$date": 1468374808864
    }
  }
}*/

#define PI radians(180.)

void main() {
  float numQuads = floor(vertexCount / 4.);
  float quadId = floor(vertexId / 4.);
  float down = floor(sqrt(numQuads));
  float across = floor(numQuads / down);

  float gx = mod(quadId, across);
  float gy = floor(quadId / across);

  float vId = mod(vertexId, 4.);

  float x = gx + mod(vId, 2.) - step(3., vId);
  float y = gy + step(3., vId);

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(x, y) / vec2(across, down) * 2. - 1.;
  gl_Position = vec4(xy * aspect * 1.1, 0, 1);

  v_color = vec4(vec3(0), 1);
}