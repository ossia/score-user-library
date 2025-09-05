/*{
  "DESCRIPTION": "lazer - 2017-07-13: replace missing music",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/nr3EiyXWLMpwoouHt)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1400,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0.01568627450980392,
    0.11372549019607843,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 842,
    "ORIGINAL_LIKES": 6,
    "ORIGINAL_DATE": {
      "$date": 1445837731814
    }
  }
}*/

/*

  ^
 /|\
  |
  +-- click hide then ...

        __ .__
  _____ _______ __ ____ _/ |_| |__ ____ _____ ____ __ __ ______ ____
 / \ / _ \ \/ // __ \ \ __\ | \_/ __ \ / \ / _ \| | \/ ___// __ \
| Y Y ( <_> ) /\ ___/ | | | Y \ ___/ | Y Y ( <_> ) | /\___ \\ ___/
|__|_| /\____/ \_/ \___ > |__| |___| /\___ > |__|_| /\____/|____//____ >\___ >
      \/ \/ \/ \/ \/ \/ \/

*/

#define PI radians(180.0)
#define NUM_SEGMENTS 2.
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0
//#define FIT_VERTICAL

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float snd = texture(sound, vec2(0.1, 0.0)).r;
  float localTime = time * 0.01 + snd * 0.0;
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS + snd);
  float count = floor(vertexId / NUM_POINTS + snd);
  float offset = count * sin(localTime * 0.01) + 5.0;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = pow(count * 0.014, 1.0);
  float c = cos(angle + localTime) * radius;
  float s = sin(angle + localTime) * radius;
  float orbitAngle = pow(count * 0.0025, 0.8);
  float innerRadius = pow(count * 0.00005, 1.2);
  float oC = cos(orbitAngle + count * 0.00001) * innerRadius;
  float oS = sin(orbitAngle + count * 0.00001) * innerRadius;

  #ifdef FIT_VERTICAL
    vec2 aspect = vec2(resolution.y / resolution.x, 1);
  #else
    vec2 aspect = vec2(1, resolution.x / resolution.y);
  #endif

  vec4 m = texture(touch, vec2(0., count / 1400.));
  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect + m.xy * 1.4, 0, 1);

  //float b = mix(0.0, 0.7, step(0.5, mod(count + localTime * 1.0, 6.0) / 2.0));
  float b = 1.0 - pow(sin(count * 0.4) * 0.5 + 0.5, 10.0);
  b = 0.0;mix(0.0, 0.7, b);
  float hue = snd;
  float sat = 1.0 - fract(count * 0.01);
  float val = snd * 2.0;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}