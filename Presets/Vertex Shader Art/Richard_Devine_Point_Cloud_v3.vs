/*{
  "DESCRIPTION": "Richard Devine Point Cloud v3",
  "CREDIT": "macro (ported from https://www.vertexshaderart.com/art/h55dGWLy6iRdoRh3j)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Particles",
    "Nature"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 9,
    "ORIGINAL_DATE": {
      "$date": 1522428289602
    }
  }
}*/



/*
   point cloud vs spheres by Kabuto remix by Macro Machines
   Recreated this well-known demo effect. A bit tricky without being able to store history for points, so it's just computed again and again for each render pass
*/

#define RATE 1.0
#define SND 1.5
#define SND2 1.0
#define BPM 172.0

vec3 posf2(float t, float i) {
 return vec3(
      sin(t+i*.18293) +
      sin(t*1.311+i) +
      sin(t*1.4+i*1.53) +
      sin(t*1.844+i*.76),
      sin(t+i*.74553+2.1) +
      sin(t*1.311+i*1.1311+2.1) +
      sin(t*1.4+i*1.353-2.1) +
      sin(t*1.84+i*.476-2.1),
      sin(t+i*1.5553-2.1) +
      sin(t*1.311+i*1.1-2.1) +
      sin(t*1.4+i*1.23+2.1) +
      sin(t*1.84+i*.36+2.1)
 )*0.1492;
}

vec3 posf0(float t) { return posf2(t,-1.)*RATE;}
vec3 posf(float t, float i) { return posf2(t*.3,i) + posf0(t);}
vec3 push(float t, float i, vec3 ofs, float lerpEnd) {
  vec3 pos = posf(t,i)+ofs;
  vec3 posf = fract(pos+0.5)-0.5;
  float l = length(posf)*1.45;
  return (- posf + posf/l)*(1.-smoothstep(lerpEnd,1.,l));
}

void main() { // more or less random movement
  float tempo = 0.125*time*BPM/60.0;
  float ramp = fract( tempo*2. );
  float sine = sin(tempo);
  float t = time*.10;
  float i = vertexId+sin(vertexId)*0.10;
  vec3 pos = posf(t,i);
  vec3 ofs = vec3(0);
  vec3 colmod = vec3(0.);
  for (float f = -10.; f < 0.; f++) {
     float nn = f<-5.?0.0001:1.;
     float snd = texture(sound,vec2(-f*0.1,i*-f*0.1*nn)).r*SND;
    ofs += push(t+f*.105*snd,i,ofs,2.-exp(-f*.1*snd));
     ofs -= snd*0.2;
     ofs += SND*0.05;
     ofs *= nn;
  }
  float snd2 = texture(sound,vec2(pos.yz)).r*SND2;
  snd2*= ramp/sin(time*1.70);//*i;//*0.01;
  ofs += push(t+snd2,i,ofs,0.999);
  pos -= posf0(t);
  pos += ofs;
  pos.yz *= mat2(.8,.6,-.6,.8);
  pos.xz *= mat2(.8,.6,-.6,.8);
  pos *= 1.;
  pos.z += 0.7;
  float moddepth = mix(0.2, 0.5, ramp*snd2);
  pos.xy *= moddepth/pos.z;

  gl_Position = vec4(pos.x, pos.y*resolution.x/resolution.y, pos.z*.1, 1);
  float size = 1.0/pos.z* 0.1+1.;
  size = clamp(size, 0.51, 2.0);
  gl_PointSize = size;

  //gl_Position.z -= 1.*sine;

  v_color = vec4(abs(ofs/max(length(ofs),1e-9))*.3+.7,1)*vec4(0.357, 0.470, 0.97, 0.23);
}