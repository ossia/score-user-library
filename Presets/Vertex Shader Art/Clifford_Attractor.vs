/*{
  "DESCRIPTION": "Clifford Attractor - You can change the shape of the attractor by moving the cursor.\nMusic also affects the shape.",
  "CREDIT": "pheema (ported from https://www.vertexshaderart.com/art/jg5dRsCi6xDSFyCJ9)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 16384,
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
    "ORIGINAL_VIEWS": 314,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1449754042490
    }
  }
}*/

#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)

const float kPI = 3.1415926535;

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float row_freq_amp = texture(sound, vec2( 1.0/240.0, 0.0)).r;
  float high_freq_amp = texture(sound, vec2( 239.0/240.0, 0.0)).r;
  float a = -1.4 * (1.0 + 0.5 * sin(2.0 * kPI * (sqrt(0.0005) * time + 0.5 * mouse.x + 0.05 * row_freq_amp)));
  float b = 1.6;
  float c = 1.0 * (1.0 + 0.5 * sin(2.0 * kPI * (sqrt(0.0007) * time + 0.5 * mouse.y + 0.01 * high_freq_amp)));;
  float d = 0.7;
  float x = 0.0;
  float y = 0.0;

  for(int i = 1; i >= 0; ++i)
  {
    if (i >= int(vertexId)) break;
   float x_tmp = x;
    x = sin(a * y) + c * cos(a * x);
    y = sin(b * x_tmp) + d * cos(b * y);
  }
  x *= 0.5 * (resolution.y / resolution.x);
  y *= 0.5;
  gl_Position = vec4(x, y, 0.0, 1.0);
  v_color = vec4(hsv2rgb(vec3(vertexId / vertexCount, 1.0, 1.0)), 0.1);
}