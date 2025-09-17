/*{
  "DESCRIPTION": "Circle! - Enjoy xd",
  "CREDIT": "dertrackererpro (ported from https://www.vertexshaderart.com/art/t6BweGrbMSz3TPJen)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1000,
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
    "ORIGINAL_VIEWS": 155,
    "ORIGINAL_DATE": {
      "$date": 1540803422225
    }
  }
}*/

//Rotation speed
const float Speed = 0.6;

//Rotation Matrix
mat2 Rotate2D (float x) {
  float a=sin(x), b=cos(x);
  return mat2(b, -a, a, b);
}

void main() {
  vec2 pos = vec2(vertexId/vertexCount*1.5, Speed*sin(time)*0.5) * Rotate2D(Speed*time+vertexId);
  vec3 clr = vec3(pos.x, pos.y, -pos.x);

  gl_PointSize = abs(pos.x)+abs(pos.y)*15.0;
  gl_Position = vec4(pos, 0.0, 1.0);
  v_color = vec4(clr, 1.0)+0.3;
}