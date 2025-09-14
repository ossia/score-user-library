/*{
  "DESCRIPTION": "119hb matrix rain - 119 bytes",
  "CREDIT": "zug (ported from https://www.vertexshaderart.com/art/MjsCC6T8BoLYtnpKv)", "ISFVSN": "2", "MODE":
"VERTEX_SHADER_ART", "CATEGORIES": [ "Math", "Animated"
  ],
  "POINT_COUNT": 2242,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1517480471310
    }
  }
}*/

void main() {
  gl_Position = vec4(vertexId / vertexCount * 7.461 - 6.,
                     cos(mod(vertexId / time, 3.) - vertexId + time), 0, 1);
  v_color = vec4(0, 1, 0, 1);
}
