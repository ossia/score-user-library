/*{
  "DESCRIPTION": "nice error 1",
  "CREDIT": "staeter (ported from https://www.vertexshaderart.com/art/6hsoh4en6G7rPqjb8)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 38729,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1705072487738
    }
  }
}*/

#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// complex numbers
// vec2(real part, complex part)
vec2 cProd(vec2 a, vec2 b) {
  return vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x);
}
float cModSqrd(vec2 a) {
  return (a.x*a.x + a.y*a.y);
}
int mandelbrot(float x, float y) {
  int n = 0;
  vec2 z = vec2(0,0);
  vec2 c = vec2(x,y);

  // no loops in glsl so jsut repeat 100 times
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;
  z = cProd(z,z) + c; n++; if(abs(cModSqrd(z))>4.) return n;

  return n;
}

void main() {
  float resArea = resolution.x * resolution.y;
  float areaPerVertex = resArea/vertexCount;
  float vertLen = sqrt(areaPerVertex);
  float vertAcrossX = floor(resolution.x/vertLen);
  float vertAcrossY = floor(resolution.y/vertLen);

  float u = (mod(vertexId, vertAcrossX))/(vertAcrossX);
  u = (u - 0.5) * 2.;
  float v = (floor(vertexId / vertAcrossX))/(vertAcrossY);
  v = (v - 0.5) * 2.;

  float x = u * (resolution.x/resolution.y) / v;
  float y = v * (resolution.y/resolution.x) / vertLen;

  gl_Position = vec4(u, v, 0, 1);
  gl_PointSize = vertLen*1.05/2.;

  v_color = vec4(hsv2rgb(vec3((x+y)/vertLen+time/10., 1., 1.)), 1.);
}