/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "artramo (ported from https://www.vertexshaderart.com/art/rM3dTWcBEhMiFfgEm)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 2,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1544028785711
    }
  }
}*/


void main () {

  float x = vertexId * .1;
  float y = vertexId * .1;

  gl_Position = vec4(x,y,0,1);

  gl_PointSize = 20.0;

  v_color = vec4(1,0,0,1);
}