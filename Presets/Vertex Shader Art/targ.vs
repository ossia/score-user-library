/*{
  "DESCRIPTION": "targ",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/42ESv42tR52CEdX63)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 6000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0.6980392156862745,
    0.09019607843137255,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 151,
    "ORIGINAL_DATE": {
      "$date": 1446026265800
    }
  }
}*/

#define PI 3.14159
#define NUM_SEGMENTS 20.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0
//#define FIT_VERTICAL

void main() {
  float localTime = time + 20.0;
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float offset = count * sin(time * 0.01) + 5.0;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float snd = texture(floatSound, vec2(count / 10000.0, 0)).a;
  float radius = pow(count * 0.014, 1.0) + snd * 0.03;
  float c = cos(angle + localTime) * radius;
  float s = sin(angle + localTime) * radius;
  float orbitAngle = pow(count * 0.025, 0.8);
  float innerRadius = pow(count * 0.0005, 1.2);
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
  gl_Position = vec4(xy * aspect + mouse * 0.1, 0, 1);

  float b = clamp(40.0 + snd, 0.0, 1.0);
  vec3 bk = vec3(178.0 / 255.0, 23.0 / 255.0, 0);
  v_color = vec4(mix(bk, vec3(0,0,0), b), 1);
}