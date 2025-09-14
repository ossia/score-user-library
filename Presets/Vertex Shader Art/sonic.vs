/*{
  "DESCRIPTION": "sonic",
  "CREDIT": "rojun (ported from https://www.vertexshaderart.com/art/CXBRMQmfvMpA4bK9H)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 5000,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1677958687666
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

void main() {
  float v = vertexId / vertexCount;

  vec2 sxy = vec2(0.1, 0.0);
  vec4 ts = texture(sound, sxy);
  vec4 tt = texture(sound, mix(vec2(0.0,0.0), vec2(0.0,0.4), v * ts.r));
  float x = (sin(20.0 * PI * v * ts.r + time)) * log(ts.a / (1.0 - tt.r));

  float y = cos(30.0 * PI * v * (ts.r));
  vec2 xy = vec2(x, y) * 0.5;
  gl_Position = vec4(xy, 0, 1);

   gl_PointSize = (10.0 * v + 0.1);

  //float hue = (time * 0.01 + count * 1.001);
  v_color = vec4(hsv2rgb(vec3(tt.r * 4.0, v, 1)), 1);
  //v_color = vec4( ts.rgb, 1.0);
  //v_color = vec4(1,1,1,1);
}
