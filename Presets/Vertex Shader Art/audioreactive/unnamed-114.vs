/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "andris (ported from https://www.vertexshaderart.com/art/Yn396rtWBPwEkd3fo)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 55940,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 92,
    "ORIGINAL_DATE": {
      "$date": 1583524345135
    }
  }
}*/

#define T radians(360.)
#define N 100.
#define f float
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
float h(float p) { vec2 p2 = fract(vec2(p*5.3983, p*5.4427)); p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
  return fract(p2.x*p2.y*95.4337);
}
vec3 h3(f s) { return vec3(h(s),h(s*.731),h(s*1.319))*2.-1.; }
vec2 r(vec2 p,f a) { return vec2(p.x*cos(a)-p.y*sin(a), p.x*sin(a)+p.y*cos(a)); }
vec3 c(f s, f b) {
  f a = h(s*0.911)*3.;
  vec3 p = h3(s), A = vec3(1.-step(.5,a));
  A.y = 1.-step(1.5,a)-A.x;
  A.z = 1.-step(2.5,a)-A.x-A.y;
  p = mix(step(0.,p)*2.-1.,p,mix(1.-A,A,b));
  return p;
}
void main() {
  f v = vertexId, t = time*3., w = resolution.x / resolution.y;
  float cc = floor(vertexId / 8.);
  vec3 p0 = c(v+t*0.132,sin(t*.2));
  f n = length(p0);
  float snd = texture(sound, vec2(n/2.,0)).r;
  vec3 p = mix(p0/n*(1.0+snd),vec3(r(p0.xy,snd),p0.z),cos(t*.54));
  p.xy = r(p.xy,t*5.*snd*0.00001);
  p.xz = r(p.xz,t*.15);
  gl_Position = vec4(p.x,p.y*w,p.z,p.z+5.);
  v_color = vec4(hsv2rgb(vec3((time * 0.01 + p0.z * 1.001), snd*10., 1./n)), 1);
  gl_PointSize=2.;
}