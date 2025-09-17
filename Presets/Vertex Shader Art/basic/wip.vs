/*{
  "DESCRIPTION": "wip",
  "CREDIT": "staeter (ported from https://www.vertexshaderart.com/art/BrGxYaWHdj7D4XZyf)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 37844,
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
      "$date": 1705069098279
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
  float resX = resolution.x;
  float resY = resolution.y;
  float resArea = resX * resY;
  float areaPerVertex = resArea/vertexCount;
  float vertLen = sqrt(areaPerVertex);
  float vertCountX = floor(resX/vertLen);
  float vertCountY = floor(resY/vertLen);

  float u = (mod(vertexId, vertCountX)-0.5)/(vertCountX-1.);
  u = (u - 0.5)*2.;
  float v = (floor(vertexId / vertCountX)-0.5)/(vertCountY-1.);
  v = (v - 0.5)*2.;

  float x = u * (resolution.x/2.);
  float y = v * (resolution.y/2.);

  gl_Position = vec4(u, v, 0, 1);
  gl_PointSize = vertLen*1.05;

  float black = 1.;
  if( y>0. || x>0. )
    black = 0.;
  v_color = vec4(hsv2rgb(vec3((x+y)/vertLen+time/10., 1., black)), 1.);
}