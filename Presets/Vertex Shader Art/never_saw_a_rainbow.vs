/*{
  "DESCRIPTION": "never saw a rainbow",
  "CREDIT": "visy (ported from https://www.vertexshaderart.com/art/DQtN9os6r9QqLMWeq)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 26330,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 435,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1447003788420
    }
  }
}*/

#define PI 3.14159
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0
//#define FIT_VERTICAL

void main() {

  float localTime = 0.01 + time*0.1;
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float offset = count * sin(localTime * 0.01) + 5.0;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = pow(count * 0.00014, 1.0);
  float c = cos(angle + localTime) * radius;
  float s = sin(angle + localTime) * radius;
  float orbitAngle = pow(count * 0.025, 0.8);
  float innerRadius = pow(count * 0.0005, 4.0-time*0.05);
  float oC = cos(orbitAngle + count * 0.0001) * innerRadius;
  float oS = sin(orbitAngle + count * 0.0001) * innerRadius;

  #ifdef FIT_VERTICAL
    vec2 aspect = vec2(resolution.y / resolution.x, 1);
  #else
    vec2 aspect = vec2(1, resolution.x / resolution.y);
  #endif

  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect * time*0.01, 0, 1);

  //float b = mix(0.0, 0.7, step(0.5, mod(count + localTime * 1.0, 6.0) / 2.0));
  float b = 1.0 - pow(sin(count * 0.4) * 0.5 + 0.5, 10.0);
  float cr = mix(0.0, 1.0, b+count*oC);
  float cg = mix(0.0, 1.0, b+count*time*0.0000001);
  float cb = mix(0.0, 1.0, b+count*oS);

  v_color = vec4(cr, cg, cb, 1);
}