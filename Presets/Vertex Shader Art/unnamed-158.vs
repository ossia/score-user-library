/*{
  "DESCRIPTION": "unnamed - Use for testing exactly how multiplies and powers transform the raw sound texture values that you're sampling.",
  "CREDIT": "sylistine (ported from https://www.vertexshaderart.com/art/mmn5xXR2yHGyorvsd)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1503432045556
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 4.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float dotsPerRow = 250.;
  float dotsPerColumn = floor(vertexCount / dotsPerRow);

  float x = mod(vertexId, dotsPerRow);
  float y = floor(vertexId / dotsPerRow);
  vec2 pos = vec2(x, y);
  pos *= vec2(1, resolution.x / resolution.y);
  pos -= vec2(dotsPerRow * 0.5, dotsPerColumn * 0.5);
  pos *= 1. / (2. * 2. * 2. * 2. * 2. * 2. * 2. * 2.);
  gl_Position = vec4(pos, 0, 1);
  float c = texture(sound, vec2(x / dotsPerRow, y / dotsPerColumn)).r;
  c = pow(c * 1.5, 3.) - 0.25;
  v_color = vec4(c, c, c, 0);
  gl_PointSize = 4.;
}