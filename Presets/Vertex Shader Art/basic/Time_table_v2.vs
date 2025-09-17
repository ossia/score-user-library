/*{
  "DESCRIPTION": "Time table v2",
  "CREDIT": "radim (ported from https://www.vertexshaderart.com/art/oBkFr7rtycBbgMasK)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 8323,
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
    "ORIGINAL_VIEWS": 12,
    "ORIGINAL_DATE": {
      "$date": 1554935341646
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 6.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {

  float halfpoint = floor(vertexId / 2.0);
  float chooser = mod(vertexId, 2.0);
  float timestep = floor(4.0*time+1.0);

  float a = halfpoint*(1.0+timestep*chooser);
  float b = mod(a, NUM_SEGMENTS);
  float stepper = mod(halfpoint,NUM_SEGMENTS*STEP)/STEP;
  float combine = mod(stepper+b, NUM_SEGMENTS);
  float cno = combine/NUM_SEGMENTS;

  vec2 points = 0.5*vec2(cos(cno*2.0*PI), sin(cno*2.0*PI));
  vec2 aspect = vec2(1, resolution.x / resolution.y);
  gl_Position = vec4((points)*aspect, 0.0, 1.0);
  float hue = stepper/NUM_SEGMENTS;
  //float hue = floor(mod((vertexId/2.0),NUM_PARTS)/(NUM_PARTS/4.0))/4.0;
  v_color = vec4(hsv2rgb(vec3(hue, 1.0, 1.0)), 1.0);
}