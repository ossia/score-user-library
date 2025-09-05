/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "ivan (ported from https://www.vertexshaderart.com/art/Mdfu3bDECkPeKcnKH)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 3,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.19215686274509805,
    0.35294117647058826,
    0.6,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1543842182757
    }
  }
}*/

void main() {
  gl_PointSize = 3.0;

  vec2 xy = vec2(-0.5, 0);

  if (vertexId == 1.0)
    xy = vec2(0, 0.5);
  else if (vertexId == 2.0)
    xy = vec2(0.5, 0);

  xy += vec2(0, sin(time));

  gl_Position = vec4(xy, 0.0, 1.0);

  v_color = vec4(0.65, 0.8, 0.4, 1);
}