/*{
  "DESCRIPTION": "neurovelho2",
  "CREDIT": "visy (ported from https://www.vertexshaderart.com/art/WvKKxjSusH6cFyYcx)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 59825,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1601,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1445821645802
    }
  }
}*/

#define PI 3.14159
//#define FIT_VERTICAL

void main() {
  float NUM_SEGMENTS =2.0;
  float NUM_POINTS = (NUM_SEGMENTS * 1.0);
  float STEP = time*0.0001;
  if (STEP > 0.003) STEP = 0.003;
  float localTime = time*0.1 + 20.0;
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float offset = count * sin(time * localTime*0.0001) + 5.0;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = pow(count * 0.00014, 1.0);
  float c = cos(angle + localTime) * radius;
  float s = sin(angle + localTime) * radius;
  float orbitAngle = pow(count * 0.025, 0.8);
  float innerRadius = pow(count * 0.0005, 1.2);
  float oC = cos(orbitAngle + count * 0.0001+0.3*cos(time*0.1+c)) * innerRadius;
  float oS = sin(orbitAngle + count * 0.0001+0.3*sin(time*0.1+orbitAngle)) * innerRadius;

  #ifdef FIT_VERTICAL
    vec2 aspect = vec2(resolution.y / resolution.x, 1);
  #else
    vec2 aspect = vec2(1, resolution.x / resolution.y);
  #endif

  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect, 0, 1);

  //float b = mix(0.0, 0.7, step(0.5, mod(count + localTime * 1.0, 6.0) / 2.0));
  float b = 1.0 - pow(sin(count * 0.4) * 0.5 + 0.5, 10.0);
  b = 0.0;mix(0.0, 0.7, b);
  v_color = vec4(1.0-b, 1.0-c*10.0, 1.0-s*10.0, 1);
}