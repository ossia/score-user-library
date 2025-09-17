/*{
  "DESCRIPTION": "rgb cube",
  "CREDIT": "andris (ported from https://www.vertexshaderart.com/art/2GJcwJ2YQaAJsasSb)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 40000,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1583619179344
    }
  }
}*/

float h(float p){return fract(fract(p*5.3983)*fract(p*.4427)*95.4337);}
vec2 r(vec2 p,float a){return vec2(-1,1)*p.yx*sin(a)+p.xy*cos(a);}
void main(){
  vec3 p=vec3(h(vertexId),h(vertexId*.731),h(vertexId*1.319))-.5;
  v_color=vec4(p+.7,1);
  p.xy=r(p.xy,time);
  p.xz=r(p.xz,time*2.);
  gl_Position=vec4(p.x,p.y*resolution.x/resolution.y,p.z,p.z+1.5);
  gl_PointSize=2.;
}