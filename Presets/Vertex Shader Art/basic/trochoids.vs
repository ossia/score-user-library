/*{
  "DESCRIPTION": "trochoids - spinning breathing trochoids",
  "CREDIT": "argonblue (ported from https://www.vertexshaderart.com/art/rXA7dW2QF9uYGive2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 12600,
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
    "ORIGINAL_VIEWS": 285,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1651354874048
    }
  }
}*/

#define PI radians(180.)

#define imod(a, b) ((a) - (b)*((a)/(b)))
#define CS(th) (vec2(cos(th), sin(th)))
#define N(v) (normalize(vec2(-(v).y, (v).x)))

#define NFIGS 7

#define V_PER_SEG 9
#define P_PER_FIG (int(vertexCount)/(NFIGS*V_PER_SEG))
#define V_PER_FIG (P_PER_FIG * V_PER_SEG)

#define SPIN 0.5
#define BREATHE 0.1

#define LINEWIDTH 10.
#define ORBIT 0.18
#define R_ORBIT 0.63

void init_figs(out vec2 a[NFIGS]) {
  a[0] = vec2(-3, 1);
  a[1] = vec2(3, 1);
  a[2] = vec2(5, 1);
  a[3] = vec2(3, 1);
  a[4] = vec2(5, 2);
  a[5] = vec2(7, 2);
  a[6] = vec2(-2, 1);
}

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Triangles for main rect of line segment
vec2 rect_tri(vec2 pn[3], int vnum, float nlw) {
  vec2 n = N(pn[1] - pn[0]);
  vec2 wv = 0.5 * n * nlw;
  mat3 pm = mat3(vec3(pn[0], 0),
        vec3(pn[1], 0),
        vec3(wv, 0));
  // This vertex order allows easier visualization
  // using LINE_STRIP
  vec3 ops[6];
  // No array initializers in ES 100...
  // Columns of pm are (pn[0], pn[1], wv)
  ops[0] = vec3(1, 0, 1);
  ops[1] = vec3(1, 0, -1);
  ops[2] = vec3(0, 1, -1);
  ops[3] = vec3(0, 1, 1);
  ops[4] = vec3(1, 0, 1);
  ops[5] = vec3(0, 1, -1);
  // Work around constant-index-expression...
  for (int i = 0; i < 6; i++) {
    if (vnum == i) {
      return (pm * ops[i]).xy;
    }
  }
}

// Bevel triangle to fill joints
vec2 bevel_tri(vec2 pn[3], int vnum, float nlw) {
  vec2 n1 = N(pn[1] - pn[0]);
  vec2 n2 = N(pn[2] - pn[1]);
  // Cross product to decide which side to draw on
  vec3 s = cross(vec3(n1, 0), vec3(n2, 0));
  float d = -sign(s.z) * 0.5 * nlw;
  mat3 pm = mat3(vec3(pn[1], 0),
        vec3(n1 * d, 0),
        vec3(n2 * d, 0));
  bvec2 sel = equal(ivec2(0, 1), ivec2(vnum));
  return (pm * vec3(1, sel)).xy;
}

// Thick line triangulation
vec2 genvert(vec2 pn[3], int vnum, float lw) {
  float nlw = lw/min(resolution.x, resolution.y);
  if (vnum < 6) {
    return rect_tri(pn, vnum, nlw);
  } else {
    return bevel_tri(pn, vnum - 6, nlw);
  }
}

// Actual trochoid calculation
vec2 curvepoint(float th, float ph, float a, float b, float rph) {
  vec2 p1 = CS(b*th);
  vec2 p2 = CS((b-a)*th+ph/b);
  float r = cos(rph);
  r = 1.-(r*r);
  return 0.21 * vec2(mix(p1, p2, r));
}

vec2 fig(vec2 fig, int vnum, float pnum, float bph, float lw) {
  float pmax = float(P_PER_FIG);
  float ph = 2.*PI*time*SPIN;
  float rph = 2.*PI*time*BREATHE + bph;
  vec2 pn[3];
  float th;
  for (int i = 0; i < 3; i++) {
    th = 2.*PI*((pnum-float(2-i))/(pmax-1.));
    pn[i] = curvepoint(th, ph, fig[0], fig[1], rph);
  }
  return genvert(pn, vnum, lw);
}

void main() {
  gl_PointSize = 4.;

  vec2 figs[NFIGS];
  init_figs(figs);

  int fnum = int(vertexId)/V_PER_FIG;
  // Vertex number within a line segment
  int vnum = imod(int(vertexId), V_PER_SEG);
  float pnum = float(imod(int(vertexId), V_PER_FIG)/V_PER_SEG);
  float pmax = float(P_PER_FIG);

  float bph = 2.*PI*float(fnum)/float(NFIGS);
  vec2 xy;
  for (int i = 0; i < NFIGS; i++) {
    if (i != fnum) { continue; }
    xy = fig(figs[i], vnum, pnum, bph, LINEWIDTH);
  }

  vec2 offset = R_ORBIT*CS(2.*PI*(float(fnum)/float(NFIGS)+time*ORBIT));
  xy += offset;

  vec2 aspect;
  if (resolution.x > resolution.y) {
    aspect = vec2(resolution.y/resolution.x, 1);
  } else {
    aspect = vec2(1, resolution.x/resolution.y);
  }
  gl_Position = vec4(xy * aspect, 0, 1);

  // v_color = vec4(.2,.8,1.,1.);
  float v = fract(time*.21+2.*pnum/pmax);
  v = 2. * mix(v, (1. - v), step(0.5, v));
  float hue = .5+.27*v;
  v_color = vec4(hsv2rgb(vec3(hue, 1, 1)), 1);
  if (fnum >= NFIGS) {
    v_color = vec4(1,1,0,1);
  }
}
