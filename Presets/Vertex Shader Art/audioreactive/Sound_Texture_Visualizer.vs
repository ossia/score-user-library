/*{
  "DESCRIPTION": "Sound Texture Visualizer - Sound\u30c6\u30ad\u30b9\u30c1\u30e3\u30fc\u306e\u30b5\u30f3\u30d7\u30eb\u3092\u3044\u3058\u308b\u3068\u3069\u3093\u306a\u30d1\u30bf\u30fc\u30f3\u3092\u7dba\u9e97\u306b\u7d5e\u308c\u308b\u304b\u3068\u306e\u305f\u3081\u306e\u30b7\u30a7\u30fc\u30c0\u30fc\u3067\u3059\u3002\n\nShader intended for viewing the raw effect of various processes on the sampled sound texture.\nHelpful for developing unique processing formulas.\n\nIn this example, I'm trying to isolate the rising and falling \"Let's go!\" sample\nThis helped also identify some really cool, clean patterns on the high end.",
  "CREDIT": "sylistine (ported from https://www.vertexshaderart.com/art/5kD5fS5JQyTcEzoY8)",
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
    "ORIGINAL_VIEWS": 190,
    "ORIGINAL_DATE": {
      "$date": 1600839950899
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 21.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float enhance(float v, float freq) {
  v *= 0.8 + freq; // enhance strength of high-end values
  v = smoothstep(0.33, 0.7, v);
  return pow(v, 4.); // enhance enhance enhance
}

void main() {
  vec2 res = resolution * 0.25;
  float width = res.x;
  vec2 vUV = vec2(mod(vertexId, width), floor(vertexId / width)) / res;

  vec2 sUV = (vUV+0.00)*0.66;
  float col = texture(sound, sUV).r;
  col = enhance(col, sUV.x);

  // attempting to use the previous frame of audio to enhance the current
  float delta = 1./480.;
  sUV.y += delta;
  float iterations = 5.;
  sUV.x -= delta * floor(iterations * 0.5);
  float col2 = 0.;
  for(float i = 1.; i <= 5.; i++) {
    float snd = texture(sound, sUV).r;
    snd = enhance(snd, sUV.x);

    //average
    /*
    float newpercent = 1. / i;
    col2 = col2 * (1. - newpercent) + snd * newpercent;
 */

    //max
    col2 = max(col2, snd);

    sUV.x += delta;
  }
  col2 *= 2.;
  col *= col2;

  gl_Position = vec4(vUV * 2. - 1., 0.0, 1.0);
  gl_PointSize = 4.0;
  v_color = vec4(col);
}