/*{
  "DESCRIPTION": "single sbd",
  "CREDIT": "andris (ported from https://www.vertexshaderart.com/art/tGQbaSaJuQ5gAAcEk)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 4000,
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
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_DATE": {
      "$date": 1583492669268
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
vec3 fk(f s,f x,f ff) {
  vec3 p = vec3(r(vec2(ff*.5,0.),T*h(s*.311)),1);
    p.xz = r(p.xz,T*floor(h(s*.731)*3.)/3.);
    p.yz = r(p.yz,T*floor(h(s)*x)/x);
  return p;
}
vec3 c(f s, f b) {
  f a = h(s*0.911)*3.;
  vec3 p = h3(s), A = vec3(1.-step(.5,a));
  A.y = 1.-step(1.5,a)-A.x;
  A.z = 1.-step(2.5,a)-A.x-A.y;
  p = mix(step(0.,p)*2.-1.,p,mix(1.-A,A,b));
  return p;
}
vec3 o(f t, f s) {
  t = floor(mod(t, 7.));
  if (t == 0.||t == 3.) return c(s,step(1.,t));
  if (t == 1.||t == 4.) return normalize(h3(s))*mix(1.,h(s*2.117),step(2.,t));
  if (t == 2.) return fk(s,3.,h(s*2.117));
  if (t == 5.) return h3(s);
  return fk(s,4.,1.);
}
void main() {
  f r = 6.,m = 1./r,t=time,a=t*.2,b=fract(time),
    u=step(.5,b),w=1.-2.*u,v=vertexId/vertexCount,s=v*4.+t*.01;
  vec3 p = mix(o(t,s),o(t+1.,s),w*pow(2.,((40.*b)-20.)*w)*.5+u),e=vec3(cos(a)*r,sin(t)*2.,sin(a)*r);
  f d = length(e), l=1./d,z=d-dot(p,e)*l;
  gl_Position=vec4((p.x*e.z - p.z*e.x)*m*2.*resolution.y/resolution.x,(p.y*r-dot(p.xz,e.xz)*e.y*m)*l*2.,z-2.,z);
  v_color = vec4(abs(p.x),p.y*cos(t*3.),abs(p.z),1);
  gl_PointSize = 18./z;
}