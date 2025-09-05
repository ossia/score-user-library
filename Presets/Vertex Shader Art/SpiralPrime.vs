/*{
  "DESCRIPTION": "SpiralPrime - Works with K-Machine app.",
  "CREDIT": "PLU Collective (ported from https://www.vertexshaderart.com/art/ghFixTy38ux4F235T)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 5000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 234,
    "ORIGINAL_LIKES": 3,
    "ORIGINAL_DATE": {
      "$date": 1498721736923
    }
  }
}*/

//SpiralPrm lines vertices 5000

//KDrawmode=GL_LINES
#define SegCntrl 2.//KParameter0 1.>>10.
#define StepCntrl 2.//KParameter1 1.>>10.
#define RadiusCntrl 0.001//KParameter2 0.001>>0.009
#define HueCntrl 1.001//KParameter3 1.001>>1.009

//KVerticesNumber=5000

#define PI radians(180.)
#define SegStepAsgn

#ifdef SegStepAsgn

float getSeg(float Sn){
 if (floor(SegCntrl) < 2.)
 {return 3.;}
 else if (floor(SegCntrl) < 3.)
 {return 5.;}
 else if (floor(SegCntrl) < 4.)
 {return 7.;}
 else if (floor(SegCntrl) < 5.)
 {return 9.;}
 else if (floor(SegCntrl) < 6.)
 {return 11.;}
 else if (floor(SegCntrl) < 7.)
 {return 13.;}
 else if (floor(SegCntrl) < 8.)
 {return 15.;}
 else if (floor(SegCntrl) < 9.)
 {return 17.;}
 else if (floor(SegCntrl) < 10.)
 {return 19.;}
 else
 {return 21.;}
}

float getStep(float Sm){
 if (floor(StepCntrl) < 2.)
 {return 2.;}
 else if (floor(StepCntrl) < 3.)
 {return 4.;}
 else if (floor(StepCntrl) < 4.)
 {return 8.;}
 else if (floor(StepCntrl) < 5.)
 {return 16.;}
 else if (floor(StepCntrl) < 6.)
 {return 23.;}
 else if (floor(StepCntrl) < 7.)
 {return 29.;}
 else if (floor(StepCntrl) < 8.)
 {return 31.;}
 else if (floor(StepCntrl) < 9.)
 {return 37.;}
 else if (floor(StepCntrl) < 10.)
 {return 41.;}
 else
 {return 43.;}
}

float temp;
#define NUM_SEGMENTS (getSeg(temp))
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP (getStep(temp))

#endif

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {

  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float snd = texture(sound, vec2(fract(count / 128.0), fract(count / 20000.0))).r;
  float offset = count * 0.02;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = 0.2 * pow(snd, 5.0);
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = count * 0.0;
  float innerRadius = count * RadiusCntrl;
  float oC = cos(orbitAngle + time * 0.4 + count * 0.1) * innerRadius;
  float oS = sin(orbitAngle + time + count * 0.1) * innerRadius;

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect + mouse * 0.1, 0, 1);

  float hue = (time * 0.01 + count * HueCntrl);
  v_color = vec4(hsv2rgb(vec3(hue, 1, 1)), 1);
}