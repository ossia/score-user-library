/*{
  "DESCRIPTION": "124b sin city - 124 bytes",
  "CREDIT": "shu (ported from https://www.vertexshaderart.com/art/Ffs2irmibSP7oFuTu)", "ISFVSN": "2", "MODE":
"VERTEX_SHADER_ART", "CATEGORIES": [ "Math", "Animated"
  ],
  "POINT_COUNT": 3840,
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
    "ORIGINAL_VIEWS": 483,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1517180447963
    }
  }
}*/

void main() {
  gl_Position = vec4(vertexId / vertexCount * 2. - 1.,
                     -tan(mod(vertexId, 99.) * vertexId + time) / 9., 0, 1);
  v_color = vec4(1, 1, 1, 1);
}
