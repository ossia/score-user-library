/*{
  "DESCRIPTION": "Animated Points",
  "CREDIT": "dertrackererpro (ported from https://www.vertexshaderart.com/art/c53eL6yrZ2W47TK9r)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 700,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 143,
    "ORIGINAL_DATE": {
      "$date": 1541014263161
    }
  }
}*/

#define VERTEX_SPEED 0.5

void main () {
  vec3 pos = vec3(cos(VERTEX_SPEED*time+(vertexId))*1.3, ((vertexId/(vertexCount-1.0))-0.5)*2.0, 0.0);
  vec3 clr = vec3(pos.x, pos.y, -pos.y)+0.2;

  gl_PointSize = 15.0;
  gl_Position = vec4(pos, 1.0);
  v_color = vec4(clr, 1.0);
}