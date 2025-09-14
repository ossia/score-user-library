/*{
  "DESCRIPTION": "wtr - 2017-07-13: Replaced missing music",
  "CREDIT": "zugzwang404 (ported from https://www.vertexshaderart.com/art/rATARASTHX6xvj5Aa)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Touch", "NAME": "touch", "TYPE": "image" }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1501616881292
    }
  }
}*/

#define PI radians(180.0)
#define NUM_SEGMENTS 200.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

void main() {
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float offset = count * sin(time * 0.01) + 5.0;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = pow(count * 0.00014, 1.0);
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float v = count / (vertexCount / NUM_SEGMENTS);
  vec2 m = texture(touch, vec2(0, v)).xy;
  float snd = texture(sound, vec2(0.05, v * 1.)).r;
  float orbitAngle = snd * PI * 2.; //pow(time + count * 0.25, 0.8);
  float innerRadius = pow(count * 0.00007, 1.2);
  float oC = cos(orbitAngle + count * 0.003 + time) * innerRadius;
  float oS = sin(orbitAngle + count * 0.004 + time * 0.01) * innerRadius;

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect * 20. * mix(0.9, 0.7, snd), 0.4, 1);

  v_color = vec4(0.3, 0.6, .7, 1. - v);
  v_color = vec4(v_color.rgb * v_color.a, v_color.a);
}