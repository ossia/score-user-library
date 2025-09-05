/*{
  "DESCRIPTION": "119b matrix - 119 bytes",
  "CREDIT": "valentin (ported from
https://www.vertexshaderart.com/art/wGx3PFi6cT8Dydevv)", "ISFVSN": "2", "MODE":
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1508333268427
    }
  }
}*/

void main() {
  gl_Position = vec4(vertexId / vertexCount * 2.1 - 1.,
                     sin(vertexId * mod(vertexId, 9.2) + time), 0, 1);
  v_color = vec4(4, 1, 5, 1);
}