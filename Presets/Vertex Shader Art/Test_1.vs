/*{
  "DESCRIPTION": "Test 1",
  "CREDIT": "sina5an (ported from https://www.vertexshaderart.com/art/LcQbjMTCCKXywR2Rb)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 60,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.24313725490196078,
    0.22745098039215686,
    0.32941176470588235,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 204,
    "ORIGINAL_DATE": {
      "$date": 1539641129864
    }
  }
}*/

void main() {
  gl_Position = vec4(cos(vertexId / 3.14 * .5 * cos(time * .25)),
        sin(vertexId / 3.14 * .5 * sin(time * .5)),
        0, 1);
  v_color = vec4(mod(vertexId, 6.0 + (cos(time))) / 5.0,
        mod(vertexId, 3.0 + (sin(time))) / 2.0
        ,0,1);
}