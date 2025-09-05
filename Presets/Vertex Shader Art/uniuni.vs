/*{
  "DESCRIPTION": "uniuni",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/WARdzeaiQZaiSy6Hj)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.7098039215686275,
    0.27058823529411763,
    0.24313725490196078,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 221,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1449082902129
    }
  }
}*/

/*

 __ __ _ _ ____ __ __ _ _ ____
( )( )( \( )(_ _)( )( )( \( )(_ _)
 )(__)( ) ( _)(_ )(__)( ) ( _)(_
(______)(_)\_)(____)(______)(_)\_)(____)

*/
#define PI radians(180.)
#define NUM_SEGMENTS 200.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

void main() {
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float maxCount = floor(vertexCount / NUM_POINTS);
  float offset = count * sin(time * 0.01) + 5.0;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = pow(count * 0.00014, 1.0);

  const int numSamples = 8;
  float snd = 0.;
  for (int i = 0; i < numSamples; ++i) {
    snd = max(texture(sound, vec2(
      0.05+ float(i) / float(numSamples) * 0.00 + 0.01,
      count / maxCount)).a, snd);
  }

  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = pow((maxCount - count) * mix(0.125, 0.25, sin(time * 0.25)), 0.8);
  float innerRadius = pow((maxCount - count) * 0.00005, 1.5);
  float oC = cos(orbitAngle + count * 0.001 + time) * innerRadius;
  float oS = sin(orbitAngle + count * 0.002 + time * 0.01) * innerRadius;

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect * 40. + mouse * 0.0, 0, 1);

  float b = 1.0 - pow(abs(sin(count * 0.2)) * 0.5 + 0.5, 2.0 + pow(snd+0.3, 5.) * 5.);
  v_color = vec4(vec3(b), 1);
}