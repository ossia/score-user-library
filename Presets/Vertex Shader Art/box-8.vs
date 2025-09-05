/*{
  "DESCRIPTION": "box",
  "CREDIT": "andris (ported from https://www.vertexshaderart.com/art/hJ9T5D48jyNh2Ziaf)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 23285,
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
    "ORIGINAL_VIEWS": 696,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1583560654009
    }
  }
}*/

float h(float p) { return fract(fract(p*5.3983)*fract(p*.4427)*95.4337); }
vec2 r(vec2 p,float a) { return vec2(-1,1)*p.yx*sin(a)+p.xy*cos(a); }
void main() { float t=time, o=resolution.x/resolution.y, s=vertexId+t;
 vec3 b=abs((fract(vec3(.25,.5,.125)*t)-.5)*2.), u=1.-step(.5,b)*2.,
  a=(pow(vec3(2.),(40.*b-20.)*u)*u-u+1.)*.5,p=vec3(h(s),h(s*.731),h(s*1.319))*2.-1.,
  d=1.-step(vec3(1,2,3),vec3(h(s*0.911)*3.)), v=d-vec3(0,d.xy);
 p=mix(step(0.,p)*2.-1.,p,mix(1.-v,v,a.y));
 p*=mix(1./length(p),1.,dot(a,p)*a.z-sin(t*.2)*2.*(a.x+.5));
 p.xy=r(p.xy,t*.2+a.x*.2);p.xz=r(p.xz,t*.3+a.y);
 v_color=vec4(a*.8+.2,1.); gl_Position=vec4(p.x,p.y*o,p.z,p.z+5.); gl_PointSize=2.;}