/*{
  "DESCRIPTION": "tutorial1",
  "CREDIT": "brygo1995 (ported from https://www.vertexshaderart.com/art/3gbxiT43Btfh3sY5q)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1697000180168
    }
  }
}*/

void main() {

  float across = 10.0;

  float x = mod(vertexId, 10.0);
  float y = floor(vertexId / 10.0);

  float u = x / across;
  float v = y / across;

  u += sin(time + x);
  v += sin(time + y);
  float z = 2.0 * sin(time);

  gl_Position = vec4(u, v, z, 1);

  gl_PointSize = 10.0;

  v_color = vec4(1, 0, 0, 1);

}