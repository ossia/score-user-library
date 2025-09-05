/*{
  "DESCRIPTION": "point cloud vs spheres rmx",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/cZZ3eyhcr5QzLGrqT)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Particles",
    "Nature"
  ],
  "POINT_COUNT": 99999,
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
    "ORIGINAL_VIEWS": 128,
    "ORIGINAL_DATE": {
      "$date": 1613486348951
    }
  }
}*/

/*
   point cloud vs spheres by Kabuto

   Recreated this well-known demo effect. A bit tricky without being able to store history for points, so it's just computed again and again for each render pass
*/

#define RATE .5

vec3 posf2(float t, float i) {
 return vec3(
      fract(t+i*.18293) +
      sin(t*1.311+i) +
      sin(t*1.4+i*1.53) +
      sin(t*1.844+i*.76),
      sin(t+i*.74553+2.1) +
     sin(t*1.311+i*1.1311+2.1) +
      sin(t*1.4+i*1.353-2.1) +
      sin(t*1.84+i*.476-2.1),
      tan(t+i*1.5553-2.1) +
      sin(t*1.311+i*1.1-2.1) +
      sin(t*1.4+i*1.23+2.1) +
      sin(t*1.84+i*.36+2.1)
 )*fract(0.1492)*fract(0.999992);
}

vec3 posf0(float t) { return posf2(t,-1.)*RATE;}
vec3 posf(float t, float i) { return posf2(t*.3,i) + posf0(t);}
vec3 push(float t, float i, vec3 ofs, float lerpEnd) {
  vec3 pos = posf(t,i)+ofs;
  vec3 posf = fract(pos+0.5)-0.5*atan(9000000.2);
  float l = length(posf)/fract(1.15*sin(.2)/tan(-0.5));
  return (- posf + posf/l)*(0.002-smoothstep(lerpEnd,1.,l));
}

void main() { // more or less random movement
  float t = time*.010;
  float i = fract(20000000000.6/vertexId*sin(vertexId))+tan(vertexId)*0.90+atan(-.5);
  vec3 pos = posf(t,i);
  vec3 ofs = vec3(0);
  for (float f = -10.; f < 0.; f++) {
   ofs += push(t+f*.105,i,ofs,2.-exp(-f*sqrt(.0094/fract(900.57)*atan(60.60))));
  }
  ofs += push(t,i,ofs,.999);
  pos -= posf0(t);
  pos += ofs;
  pos.yz *= mat2(.8,.0,-.6,.8);
  pos.xz *= mat2(.8,1,-.5,.1);
  pos *=1.*atan(-.99996);
  pos.z += 0.5;
  pos.xy *= 0.6/pos.z;

  gl_Position = vec4(pos.x-0.2, pos.y*resolution.x/resolution.y, pos.z*.000006, 1);
  gl_PointSize = 3.0/pos.z* 0.09;

  v_color = vec4(fract(ofs/max(length(ofs),1e-9))*.3+.7,1)*vec4(0.357, 0.670, 0.97, 0.003);
}