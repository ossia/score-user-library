/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "illus0r (ported from https://www.vertexshaderart.com/art/ju4uMD2zrxMd4z9HK)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1633087004290
    }
  }
}*/

#define rnd(x) fract(921.97 * sin(87.15 * mod(x,120.21)+.1))
#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))

void main() {
  float r = pow(fract(time*1.1+floor(rnd(vertexId)*8.)/8.+.5*rnd(vertexId)),.1);
  gl_Position = vec4(r,0, 0, 1);
  gl_Position.xy *= rot(time*.1+1e3*rnd(vertexId*.8));
  gl_Position.zy *= rot(1e3*rnd(vertexId));
  gl_PointSize=.1;
  v_color = vec4(1,0,0,1);
}
