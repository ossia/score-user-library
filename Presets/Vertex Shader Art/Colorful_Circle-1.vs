/*{
  "DESCRIPTION": "Colorful Circle",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/gbv2z926cb7MWF3Gy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 54,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 50,
    "ORIGINAL_DATE": {
      "$date": 1680860953904
    }
  }
}*/

void main() {
  vec3 pos = vec3(cos(time+vertexId)*0.7, sin(time+vertexId), 0.0);
  float color = 1.0;
  gl_PointSize = 20.0;
  gl_Position = vec4(pos, 1.0);
  v_color = vec4(pos.x, pos.y, -pos.y, 1.0)+0.5;
}