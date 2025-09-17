/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "sava\u015f (ported from https://www.vertexshaderart.com/art/S73z5kLypn9BENeFt)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 36,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.23529411764705882,
    0.23529411764705882,
    0.23529411764705882,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1529242393190
    }
  }
}*/

void main(){

  float x = vertexId / vertexCount;

  gl_PointSize = 8.0;

  gl_Position = vec4(x, 0.0, 0.0, 1.0);
  v_color = vec4(1.0, 1.0, 1.0, 1.0);

}
