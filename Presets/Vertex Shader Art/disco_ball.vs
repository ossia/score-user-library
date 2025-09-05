/*{
  "DESCRIPTION": "disco ball",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/ScnXYT2B8gmr2trfw)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 3072,
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
    "ORIGINAL_VIEWS": 941,
    "ORIGINAL_LIKES": 5,
    "ORIGINAL_DATE": {
      "$date": 1447534629459
    }
  }
}*/


//

#define PI 3.14159
#define NUM_SEGMENTS 21.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0
//#define FIT_VERTICAL

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float localTime = time + 20.0;
  float v = vertexId;
  float vertex = mod(v, 6.);
  v = (v-vertex)/6.;
  float a1 = mod(v, 32.);
  v = (v-a1)/32.;
  float a2 = v-8.;

  float a1n = (a1+.5)/32.*2.*PI;
  float a2n = (a2+.5)/32.*2.*PI;

  a1 += mod(vertex,2.);
  a2 += vertex==2.||vertex>=4.?1.:0.;

  a1 = a1/32.*2.*PI;
  a2 = a2/32.*2.*PI;

  vec3 pos = vec3(cos(a1)*cos(a2),sin(a2),sin(a1)*cos(a2));
  vec3 norm = vec3(cos(a1n)*cos(a2n),sin(a2n),sin(a1n)*cos(a2n));

  pos.xz *= mat2(cos(time),sin(time),-sin(time),cos(time));
  pos.yz *= mat2(cos(time),sin(time),-sin(time),cos(time));
  norm.xz *= mat2(cos(time),sin(time),-sin(time),cos(time));
  norm.yz *= mat2(cos(time),sin(time),-sin(time),cos(time));

  vec3 light = vec3(0);

  for (int i = 0; i < 100; i++) {
    float f=float(i);
     light += pow(dot(normalize(vec3(sin(float(i)),sin(float(i)*1.3),cos(float(i)*1.43))),norm)*.5+.5,70.)*abs(vec3(sin(f*4.2),cos(f*2.5),cos(f*1.9)))*.4;
  }

    /*

    pow(dot(normalize(vec3(.3,.4,-.5)),norm)*.5+.5,50.)*vec3(.8,.3,.2)
     + pow(dot(normalize(vec3(.1,-.2,-.5)),norm)*.5+.5,50.)*vec3(.2,.3,.8)
     + pow(dot(normalize(vec3(-.5,-.1,-.5)),norm)*.5+.5,50.)*vec3(.2,.7,.4)
     + pow(dot(normalize(vec3(.7,-.2,-.5)),norm)*.5+.5,50.)*vec3(.7,.6,.1);
  */

  gl_Position = vec4(pos.x*resolution.y/resolution.x,pos.y, pos.z*.5+.5, 1);

  v_color = vec4(vec3(light), 1);
}