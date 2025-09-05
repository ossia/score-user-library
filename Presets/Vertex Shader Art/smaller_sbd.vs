/*{
  "DESCRIPTION": "smaller sbd",
  "CREDIT": "andris (ported from https://www.vertexshaderart.com/art/KLtJG7Mcf8FhRihJn)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 60000,
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
    "ORIGINAL_VIEWS": 451,
    "ORIGINAL_LIKES": 3,
    "ORIGINAL_DATE": {
      "$date": 1583467610087
    }
  }
}*/

#define T radians(360.)
#define f float
f h(f p) {
  vec2 p2 = fract(vec2(p*5.3983, p*5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
  return fract(p2.x*p2.y*95.4337);
}
vec3 h3(f s) { return vec3(h(s),h(s*.731),h(s*1.319))*2.-1.; }
vec2 r(vec2 p,f a) { return vec2(p.x*cos(a)-p.y*sin(a), p.x*sin(a)+p.y*cos(a)); }
vec3 fk(f s, f x, f y, f ff) {
  vec3 p = vec3(r(vec2(ff*.5,0.),T*h(s*.311)),1);
    p.xz = r(p.xz,T*floor(h(s*.731)*y)/y);
    p.yz = r(p.yz,T*floor(h(s)*x)/x);
  return p;
}
vec3 c(f s, f b) {
  f a = h(s * 0.911) * 3.;
  vec3 p = h3(s), A = vec3(1.-step(.5,a));
  A.y = 1.-step(1.5,a) * 1.-A.x;
  A.z = 1.-step(2.5,a) * 1.-A.x * 1.-A.y;
  p = mix(step(0., p)*2.-1.,p,mix(1.-A,A,b));
  return p;
}
vec3 m(f t, f s) {
  t = floor(mod(t, 7.));
  if (t == 0.||t == 3.) return c(s,step(1.,t));
  if (t == 1.||t == 4.) return normalize(h3(s))*mix(1.,h(s*2.117),step(2.,t));
  if (t == 2.) return fk(s,3.,3.,h(s*2.117));
  if (t == 5.) return h3(s);
  return fk(s, 4., 3.,1.);
}
f e(f p) {
  if ((p/=.5) < 1.) return .5*pow(p,3.);
  return .5*(pow((p-2.),3.)+2.);
}
vec3 b(f t, f s) { return mix(m(t, s), m(t + 1., s), e(fract(time))); }
void main() {
  f r = 13., m = 1./r, a = time*.2, A=2.*resolution.y/resolution.x,
  v = vertexId/vertexCount, i = floor(vertexId/4e3);
  vec3 p = b(time+i,v*4.+time*.01)*(1.+.5*h(i*.8))+h3(i*.3)*6., e=vec3(cos(a)*r,sin(time),sin(a)*r);
  f d = length(e), l = 1./d, z=d-dot(p,e)*l;
  gl_Position=vec4((p.x*e.z - p.z*e.x)*m*A,(p.y*r-dot(p.xz,e.xz)*e.y*m)*l*2.,z-2.,z);
  v_color = mix(vec4(i/4.+p.y,mod(p.x+i,2.),v*p.z,1),vec4(0,1,0,1),sin(time-i*.5));
  gl_PointSize = 18./z;
}