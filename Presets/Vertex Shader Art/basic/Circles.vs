/*{
  "DESCRIPTION": "Circles",
  "CREDIT": "dertrackererpro (ported from https://www.vertexshaderart.com/art/R4LHf9BCLCCDYjbez)",
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
    "ORIGINAL_VIEWS": 222,
    "ORIGINAL_DATE": {
      "$date": 1540639677104
    }
  }
}*/

void main () {
  vec4 pos = vec4(cos(time + vertexId * 0.01) * 0.5, sin(time + vertexId * 0.01) * 0.8, 0.0, 1.0);
  gl_PointSize = 15.0;
  gl_Position = pos + vertexId*0.0006;
  v_color = vec4(pos.x, pos.y, -pos.y, 1.0) + 0.5;
}