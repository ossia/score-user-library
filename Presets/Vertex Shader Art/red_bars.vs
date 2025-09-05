/*{
  "DESCRIPTION": "red bars - It is from 404 not found",
  "CREDIT": "jarredthecoder (ported from https://www.vertexshaderart.com/art/BEskWFZM826YNBJAN)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1440,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    1,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 35,
    "ORIGINAL_DATE": {
      "$date": 1668219725824
    }
  }
}*/

// -----[ shader missing! ] -----

#define NUM 15.0
#define NUMP 2.1
void main() {
  gl_PointSize = 64.0;
  float col = mod(vertexId, NUM + 1.0);
  float row = mod(floor(vertexId / NUMP), NUMP + 1.0);
  float x = col / NUM * 2.0 - 1.0;
  float y = row / NUM * 2.0 - 1.0;
  gl_Position = vec4(x, y, 0, 1);
  v_color = vec4(fract(time + col / NUM + sin(row) / NUMP), 0, 0, 6);
}