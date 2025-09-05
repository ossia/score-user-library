/*{
  "DESCRIPTION": "q",
  "CREDIT": "ilyadorosh (ported from https://www.vertexshaderart.com/art/sfTopMcw7ctmNhjJL)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1625280390697
    }
  }
}*/

#define PI 3.14159
#define NUM_SEGMENTS 21.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0
//#define FIT_VERTICAL

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
vec3 inv(vec3 a){return 1.-a;}

void main() {
  float localTime = time + 20.0;
  float v = vertexId;
  float vertex = mod(v, 6.);
  v = (v-vertex)/6.;
  float a1 = mod(v, 32.);
  v = (v-a1)/32.;
  float a2 = v-8.;

  float a1n = (a1+.5)/32.*2.*PI;
  float a2n = (a2+.5)/32.*2.*PI;

  a1 += mod(vertex,2.);
  a2 += vertex==2.||vertex>=4.?1.:0.;

  a1 = a1/32.*2.*PI;
  a2 = a2/32.*2.*PI;

  vec3 pos = vec3(cos(a1)*cos(a2),sin(a2),sin(a1)*cos(a2));
  vec3 norm = vec3(cos(a1n)*cos(a2n),sin(a2n),sin(a1n)*cos(a2n));

  pos.xz *= mat2(cos(time),sin(time),-sin(time),cos(time));
  pos.yz *= mat2(cos(time),sin(time),-sin(time),cos(time));
  norm.xz *= mat2(cos(time),sin(time),-sin(time),cos(time));
  norm.yz *= mat2(cos(time),sin(time),-sin(time),cos(time));

  float a = pos.x;
  a = fract(sin(dot(floor(pos.xy*8.0+time*2.0),vec2(5.34,6.57)))*37.536);
  //a=2.*a-1.;
  vec3 color = vec3(a, -a, abs(a));
  color = inv(color);

  gl_Position = vec4(pos.x*resolution.y/resolution.x,pos.y, pos.z*.5+.5, 1);

  v_color = vec4(color, 1);
}