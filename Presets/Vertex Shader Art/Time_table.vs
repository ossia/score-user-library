/*{
  "DESCRIPTION": "Time table",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/YyvPGrqSH2HjWTQi9)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1024,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 117,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1554929540009
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 512.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 2.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {

  float point = mod((floor(vertexId / 2.0)*(1.0+((time+1.0)*(mod(vertexId, 2.0))))),NUM_SEGMENTS)/NUM_SEGMENTS;
  vec2 points = 0.5*vec2(cos(point*2.0*PI), sin(point*2.0*PI));
  vec2 aspect = vec2(1, resolution.x / resolution.y);
  gl_Position = vec4((points)*aspect, 0.0, 1.0);
  float hue = mod((floor(vertexId / 2.0)*(1.0+floor(time*1.0*(mod(vertexId, 2.0))))),NUM_SEGMENTS)/NUM_SEGMENTS;
  v_color = vec4(hsv2rgb(vec3(hue, 1.0, 1.0)), 1.0);
}