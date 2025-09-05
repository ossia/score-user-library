/*{
  "DESCRIPTION": "119b matrix rain - 119 bytes",
  "CREDIT": "shu (ported from
https://www.vertexshaderart.com/art/4MXkkkQvDcbZT2bmy)", "ISFVSN": "2", "MODE":
"VERTEX_SHADER_ART", "CATEGORIES": [ "Math", "Animated"
  ],
  "POINT_COUNT": 999,
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
    "ORIGINAL_VIEWS": 567,
    "ORIGINAL_DATE": {
      "$date": 1486360045610
    }
  }
}*/

void main() {
  gl_Position = vec4(vertexId / vertexCount * 2. - 1.,
                     sin(mod(vertexId, 9.) * vertexId + time), 0, 1);
  v_color = vec4(0, 1, 0, 1);
}