/*{
  "DESCRIPTION": "deneme",
  "CREDIT": "nezihesozen (ported from https://www.vertexshaderart.com/art/a5fepCCbY5AhGFXTT)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 4419,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.5019607843137255,
    0.5019607843137255,
    0.5019607843137255,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1530441600955
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 21.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

void main() {
  gl_PointSize=15.0;
  gl_Position=vec4(0.0,0.0,0.0,1.0);
  v_color=vec4(1.0,1.0,1.0,1.0);
}