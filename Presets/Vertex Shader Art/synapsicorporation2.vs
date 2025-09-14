/*{
  "DESCRIPTION": "synapsicorporation2",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/bjkZzQ6XfJ5Ypu4AX)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 61324,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "floatSound", "TYPE": "audioFloatHistogram" }, { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 137,
    "ORIGINAL_DATE": {
      "$date": 1446204598570
    }
  }
}*/

#define PI 3.14159
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0
//#define FIT_VERTICAL

// music by rez! here we goooooooo-oo-oo-oooooooo.....

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {

  float localTime = time + 20.0;

  float NUM_SEGMENTS = localTime*cos(texture(floatSound,vec2(localTime*0.0000001,cos(localTime*0.0000001))).r*0.00001);
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float offset = count * 0.02;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = 0.2+cos(texture(floatSound,vec2(count*0.01,angle*0.01)).r*0.0001*localTime);
  float c = cos(angle + localTime) * radius;
  float s = sin(angle + localTime) * radius;
  float orbitAngle = count * 0.01*texture(floatSound,vec2(localTime,s+vertexId*0.01)).r*0.01;
  float oC = cos(orbitAngle + localTime * count * 0.01) * sin(orbitAngle);

  float aa = (localTime*0.001)*cos(localTime*0.1000*vertexId);
  float oS = sin(orbitAngle + localTime * count * 0.01) * sin(orbitAngle-aa);

  #ifdef FIT_VERTICAL
    vec2 aspect = vec2(resolution.y / resolution.x, 1);
  #else
    vec2 aspect = vec2(1, resolution.x / resolution.y);
  #endif

  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect + mouse * 0.1, 0, 1);

  float hue = (localTime * 0.01 + count * 1.001);
  v_color = vec4(hsv2rgb(vec3(hue, 1, 1)), 1);
}