/*{
  "DESCRIPTION": "3D Sine Wave",
  "CREDIT": "dertrackererpro (ported from https://www.vertexshaderart.com/art/4h35MHPA2dwXFTJHy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 50000,
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
    "ORIGINAL_VIEWS": 297,
    "ORIGINAL_DATE": {
      "$date": 1540721439293
    }
  }
}*/

void main () {
  vec4 pos = vec4(-1.0, sin(2.0*time + vertexId * 0.005)-0.5 * 0.8, 0.0, 1.0);
  gl_PointSize = 15.0;
  gl_Position = pos + vertexId*0.0006;
  v_color = vec4(pos.x, pos.y, -pos.y, 1.0) + 0.5;
}