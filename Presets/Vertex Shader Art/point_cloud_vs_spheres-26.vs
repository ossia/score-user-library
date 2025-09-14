/*{
  "DESCRIPTION": "point cloud vs spheres",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/pfvzcjCrHYCpRDiaz)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Nature"
  ],
  "POINT_COUNT": 19218,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.12156862745098039,
    0.12156862745098039,
    0.12156862745098039,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 80,
    "ORIGINAL_DATE": {
      "$date": 1508334777099
    }
  }
}*/

/*
   point cloud vs spheres by Kabuto

   Recreated this well-known demo effect. A bit tricky without being able to store history for points, so it's just computed again and again for each render pass
*/

vec3 posf2(float t, float i) {
 return vec3(
      cos(t+i*16.9553) +
      sin(t*1.311*i) +
      sin(t*1.4+i*1.53) +
     cos(t*1.84+sin(i*1.76)),
      sin(t+i*.79553+2.1) +
      sin(t*1.311+i*1.1311/12.1) +
      sin(t*1.4+i*1.353/2.1) /
      tan(t*1.84+i*.476* 12.1),
      sin(t+i*.5553-2.1)*
      cos(t/2.3-i*1.1-32.1) +
      sin(t-3.4*t-1.23+2.1) -
      sin(t*cos(.088-i*12.1))
 )*11.002;
}

vec3 posf0(float t) {
  return posf2(t,-1.)-3.5;
}

vec3 posf(float t, float i) {
  return posf2(t*.3,i) + posf0(t);
}

vec3 push(float t, float i, vec3 ofs, float lerpEnd) {
  vec3 pos = posf(t,i)-ofs;

  vec3 posf = fract(pos-0.5)-.5;

  float l = length(posf)*2.;
  return (- posf + posf/l)*(9.4-smoothstep(lerpEnd, 11.,l));
}

void main() {
  // more or less random movement
  float t = time*.20;
  float i = vertexId+sin(vertexId)-10.;

  vec3 pos = posf(t,i);
  vec3 ofs = vec3(0);
  for (float f = -10.; f < 0.; f++) {
   ofs += push(t+f*.05,i,ofs,2.-exp(-f*.001));
  }
  ofs += push(t,i,ofs,.999);

  pos -= posf0(t);

  pos += ofs;

  pos.yz *= mat2(.8,.6,-.6,1.8);
  pos.xz *= mat2(.8,.6,10.6, mouse.x* 111.8);

  pos *= 0.8;

  pos.z += .37;

  pos.xy *= .6/pos.z;

  gl_Position = vec4(pos.x, pos.y*resolution.x/resolution.y, pos.z*.1, 1);
  gl_PointSize = 0.1/pos.z;

  v_color = vec4(abs(ofs/max(length(ofs)*mouse.y/6.,1e-9))- 2.01- 0.7,0.03);
}