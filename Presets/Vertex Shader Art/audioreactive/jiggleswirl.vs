/*{
  "DESCRIPTION": "jiggleswirl",
  "CREDIT": "jarredthecoder (ported from https://www.vertexshaderart.com/art/KZdmbdYsnSLLCa4bQ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 13961,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.2901960784313726,
    0.2901960784313726,
    0.2901960784313726,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 39,
    "ORIGINAL_DATE": {
      "$date": 1669432325120
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
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
  float orbitAngle = pow(count * 0.025, 0.8);
  float innerRadius = pow(count * 0.0005, 1.2);
  float oC = cos(orbitAngle + count * 0.0001) * innerRadius;
  float oS = sin(orbitAngle + count * 0.0001) * innerRadius;

  float snd = texture(sound, vec2(oC, oS)).r;

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect + snd * 0.1, 0, 1);

  float b = 1.0 - pow(sin(count * 0.4) * 0.5 + 0.5, 10.0);
  b = 0.0;mix(0.0, 0.7, b);
  v_color = vec4(b, b, b, 1);
}