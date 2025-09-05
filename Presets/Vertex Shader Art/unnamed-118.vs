/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "vincent23 (ported from https://www.vertexshaderart.com/art/ZbFWyvpmE9fXFTeD6)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 33162,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.4196078431372549,
    0.3411764705882353,
    0.49411764705882355,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 23,
    "ORIGINAL_DATE": {
      "$date": 1466934530481
    }
  }
}*/

float vdc(int n, float base)
{
 float vdc = 0.;
 float denom = 1.;
    // valid for n < 131072 (base 2)
 for (int i = 0; i < 17; i++)
 {
  denom *= base;
  vdc += mod(float(n), base) / denom;
  n /= int(base);
 }
 return vdc;
}

vec2 hammersley2d(int i, int N) {
 return vec2(float(i)/float(N), vdc(i, 2.));
}

vec3 hammersley3d(int i, int N) {
 return vec3(float(i)/float(N), vdc(i, 2.), vdc(i, 3.));
}

float cheapHash(ivec2 c) {
 int x = int(0x3504f333)*c.x*c.x + c.y;
 int y = int(0xf1bbcdcb)*c.y*c.y + c.x;
 return float(x*y)*(2.0/8589934592.0)+0.5;
}

float waterNoise(vec2 p) {
 ivec2 index = ivec2(floor(p));
 vec2 d = smoothstep(0., 1., fract(p));
 float result = 0.;
 float v00 = cheapHash(index);
 float v01 = cheapHash(index + ivec2(0, 1));
 float v10 = cheapHash(index + ivec2(1, 0));
 float v11 = cheapHash(index + ivec2(1, 1));
 return mix(mix(v00, v10, d.x), mix(v01, v11, d.x), d.y) * 2. - 1.;
}

float f2Sphere(vec2 p, float r) {
 return length(p) - r;
}

float fSphere(vec3 p, float r) {
 return length(p) - r;
}

void pTrans(inout float p, float d) {
  p -= d;
}

void pTrans(inout vec2 p, vec2 d) {
 p -= d;
}

void pTrans(inout vec3 p, vec3 d) {
 p -= d;
}

void pRot(inout vec2 p, float a) {
 p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float fTorus(vec3 p, float smallRadius, float largeRadius) {
 return length(vec2(length(p.xz) - largeRadius, p.y)) - smallRadius;
}

float vmax(vec3 v) {
 return max(max(v.x, v.y), v.z);
}

float fBox(vec3 p, vec3 b) {
 vec3 d = abs(p) - b;
 return length(max(d, vec3(0))) + vmax(min(d, vec3(0)));
}

float sgn(float x) {
 return (x<0.)?-1.:1.;
}

vec2 sgn(vec2 v) {
 return vec2(sgn(v.x), sgn(v.y));
}

float pMirror (inout float p, float dist) {
 float s = sgn(p);
 p = abs(p)-dist;
 return s;
}

// Repeat in two dimensions
vec2 pMod2(inout vec2 p, vec2 size) {
 vec2 c = floor((p + size*0.5)/size);
 p = mod(p + size*0.5,size) - size*0.5;
 return c;
}

float PI = acos(-1.);

// Repeat around the origin by a fixed angle.
// For easier use, num of repetitions is use to specify the angle.
float pModPolar(inout vec2 p, float repetitions) {
 float angle = 2.*PI/repetitions;
 float a = atan(p.y, p.x) + angle/2.;
 float r = length(p);
 float c = floor(a/angle);
 a = mod(a,angle) - angle/2.;
 p = vec2(cos(a), sin(a))*r;
 // For an odd number of repetitions, fix cell index of the cell in -x direction
 // (cell index would be e.g. -5 and 5 in the two halves of the cell):
 if (abs(c) >= (repetitions/2.)) c = abs(c);
 return c;
}

float bps = 178. / 60.;

float Tau = 2. * PI;

float f2Plane(vec2 p, vec2 n) {
 // n must be normalized
 return dot(p, n);
}

vec2 unitVector(float phi) {
 return vec2(cos(phi), sin(phi));
}

float f2PlaneAngle(vec2 p, float phi) {
 return f2Plane(p, unitVector(phi));
}

float max3(float a, float b, float c) {
 return max(max(a, b), c);
}

// r is the radius from the origin to the vertices
float f2Pentaprism(vec2 p, float r) {
 float phi1 = radians(108. / 2.);
 float phi2 = radians(-18.);
 float offset = r * cos(Tau / 5. / 2.);

 vec2 q = vec2(abs(p.x), p.y);
 float side1 = f2PlaneAngle(q, phi1);
 float side2 = -p.y;
 float side3 = f2PlaneAngle(q, phi2);

 float pentagon = max3(side1, side2, side3) - offset;

 return pentagon;
}

float f2Supershape(vec2 p, float a, float b, float m, float n1, float n2, float n3) {
 float phi = atan(p.y, p.x);
 float d = length(p);

 float m4 = m / 4.;

 float c = cos(m4 * phi);
 float s = sin(m4 * phi);

 float ca = c / a;
 float sb = s / b;

 float gc = ca < 0. ? -1. : 1.;
 float gs = sb < 0. ? -1. : 1.;

 float absc = ca * gc;
 float abss = sb * gs;

 float ab2 = pow(absc, n2);
 float ab3 = pow(abss, n3);

 //float ab21 = pow(absc, n2 - 1.);
 //float ab31 = pow(abss, n3 - 1.);
 float ab21 = ab2 / absc;
 float ab31 = ab3 / abss;

 float rw = ab2 + ab3;
 float r = pow(rw, -1./n1);

 float k = -n2 * ab21 * gc / a * s;
 float l = n3 * ab31 * gs / b * c;

 //float drpre = m4 / n1 * pow(rw, -1./n1 - 1.);
 float drpre = m4 / n1 * r / rw;
 float dr2 = drpre * drpre * (k * k + 2. * k * l + l * l);

 float f = (d - r) / sqrt(1. + dr2);
 return f;
}

float fTorusWeird(vec3 p, float scale) {
  float rBig = scale;
  float n1 = 1.;
  float n2 = (sin(time * Tau * bps / 16.) * .5 + .5) * .7 + .3;
  float n3 = (cos(time * Tau * bps / 32.) * .5 + .5) * .8 + .2;
  vec2 q = vec2(f2Supershape(p.xz, rBig, rBig, 7., n1, n2, n3), p.y);
  return f2Sphere(q, scale * .4);
}

float f(vec3 p, out int material) {
  vec3 p_box = p;
  pRot(p_box.xy, time * 0.91);
  pRot(p_box.yz, time * 0.93);
  pRot(p_box.xz, time * 0.95);
  float f_box = fTorusWeird(p_box, .2);

  pRot(p.xy, .7);
  pRot(p.xz, time * 2. * PI * bps / 8.);
  pModPolar(p.xz, 8.);
  pTrans(p.x, .7);
  pRot(p.xz, PI* 2. * 3. * p.y);
  pTrans(p.x, .01);
  float f_cylinders = f2Sphere(p.xz, .1);

  if (f_box < f_cylinders) {
    material = 0;
   return f_box;
  } else {
    material = 1;
    return f_cylinders;
  }
}

vec3 sdfNormal(vec3 p, float e) {
 vec3 s[6];
 s[0] = vec3(e,0,0);
 s[1] = vec3(0,e,0);
 s[2] = vec3(0,0,e);
 s[3] = vec3(-e,0,0);
 s[4] = vec3(0,-e,0);
 s[5] = vec3(0,0,-e);
 float d[6];
    int m;
 for(int i = 0; i < 6; i++) {
  d[i] = f(p + s[i], m);
 }
 return normalize(vec3(d[0] - d[3], d[1] - d[4], d[2] - d[5]));
}

void main() {
  float phi = vertexId * 6.28 * time;
  vec3 p = hammersley3d(int(vertexId), int(vertexCount));
  p.xy = p.xy * 2. - 1.;

  float freq = .08;
  float foo = texture(sound, vec2(freq, .0)).r;
  foo *= texture(sound, vec2(freq, .1)).r;
  foo *= texture(sound, vec2(freq, .2)).r;
  int material;
  for (int i = 0; i < 3; i++) {
 vec3 direction = -sdfNormal(p, .01);
    float d = f(p, material);
    p += d * direction * (1. - foo);
  }

  p.xy *= .9;
  p.y *= resolution.x / resolution.y;
  gl_PointSize = 10. + 3. * sin(vertexId + time * bps * 2. * PI * .25);
  gl_PointSize *= .4;
  gl_Position = vec4(p, 1);

  vec3 normal = sdfNormal(p, .01);
  vec3 lightDir = vec3(0., 0., 1.);

  float x = smoothstep(.0, .3, abs(f(p, material)));
  x = (1. - (1. - smoothstep(-.5, 1., x)));

  vec3 color = mix(vec3(186, 186, 232) / 255., vec3(231, 231, 184) / 255. ,x);
  if (material == 0) {
    gl_PointSize *= 3.;
    color = vec3(1, 0, 0);
  }
  color *= .4;
  v_color = vec4(color, .05);
}