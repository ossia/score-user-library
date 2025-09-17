/*{
  "DESCRIPTION": "a cool shape - My 2nd vertex shader, just a cool idea I wanted to try making, without much of a practical use",
  "CREDIT": "\u05d0\u05e8\u05d3 (ported from https://www.vertexshaderart.com/art/soQPRE79HZt8hAGAh)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 81,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0.5019607843137255,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 151,
    "ORIGINAL_DATE": {
      "$date": 1575841150650
    }
  }
}*/

#define TOP_WIDTH 0.4
#define BOTTOM_WIDTH 0.1
#define HEIGHT 0.5

void main(){
  float columnCount = vertexCount / 2.0;

  float ux = (floor(vertexId / 2.0) / (columnCount - 1.0) * (TOP_WIDTH - BOTTOM_WIDTH)) + BOTTOM_WIDTH;

  float x = (mod(vertexId, 2.0) * 2.0 - 1.0) * ux;
  float y = sqrt(floor(vertexId / 2.0) / (columnCount - 1.0)) * HEIGHT;

  gl_PointSize = 10.0;

  gl_Position = vec4(x, y, 0.0, 1.0);

  float baseColor = mod(vertexId, vertexCount) / vertexCount;
  v_color = vec4(baseColor, 1.0 - baseColor, 1.0, 1.0);
}