/*{
  "DESCRIPTION": "Oh my word",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/rghHKREPitTaTLiyH)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 22578,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.17647058823529413,
    0.25098039215686274,
    0.3215686274509804,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 64,
    "ORIGINAL_DATE": {
      "$date": 1642024013721
    }
  }
}*/



#define PI radians(180.)
#define NUM_SEGMENTS 1.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.3
void main() {
    float T = cos( time*mod(floor(vertexId / 2.0) * -mod(vertexId, 2.0) * STEP, NUM_SEGMENTS));

  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float offset = count * sin(time * 0.01) + 5.0;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = pow(count * 0.00014, 1.0);
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = pow(count * 0.025, .9);
  float innerRadius = pow(count * 0.0005, .2);
  float oC = cos(orbitAngle + count * 0.0001) * innerRadius*mouse.y;
  float oS = sin(orbitAngle + count * 0.01) * innerRadius*mouse.x;

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c+oS,
      oS + s+c);
  gl_Position = vec4(xy * aspect * 0.90161, sin(time), 1);

  float b = 1.2 - pow(sin(count * 0.4+T) * 1.3 + 0.7, 1.8);
  b = 0.0;mix(0.3, 0.7, b);
  v_color = vec4(c, b, sin(T*.1)+c*b, 0.6);
}
