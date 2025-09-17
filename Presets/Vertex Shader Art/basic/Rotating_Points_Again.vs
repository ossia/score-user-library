/*{
  "DESCRIPTION": "Rotating Points! *Again*",
  "CREDIT": "dertrackererpro (ported from https://www.vertexshaderart.com/art/YNECMxcrupx4erT4u)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 300,
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
    "ORIGINAL_VIEWS": 162,
    "ORIGINAL_DATE": {
      "$date": 1541270385383
    }
  }
}*/

mat2 Rotate2D(float x) {
  float a=sin(x), b=cos(x);
  return mat2(b, -a, a, b);
}

void main () {
  vec3 pos = vec3((vertexId/vertexCount)*2.0, 0.0, 0.0);
  pos.xy *= Rotate2D(time+vertexId*2.0);
  vec3 clr = vec3(pos.x, pos.y, -pos.x)+0.3;
  pos.y*=0.3;
  pos.yz *= Rotate2D(time)*2.0;

  gl_PointSize = 3.0;
  gl_Position = vec4(pos, 1.0);
  v_color = vec4(clr, 1.0);
}