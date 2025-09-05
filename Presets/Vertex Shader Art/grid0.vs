/*{
  "DESCRIPTION": "grid0",
  "CREDIT": "pgan (ported from https://www.vertexshaderart.com/art/emCzESvMqeynBHRzP)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 43209,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1554726621854
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

void main() {
  //background = vec4(0.0, 0.1, 0.0, 1.0);
  float magic = 10.0;
  float x = mod(vertexId, magic);
  float y = floor(vertexId / magic);

  gl_Position = vec4(x/magic-magic/2.0, y/magic-magic/2.0, 0.0, 1.0);
  vec4 v_color = vec4(0.0, 1.0, 0.0, 1.0);
  gl_PointSize = 10.0;
}
