/*{
  "DESCRIPTION": "Oh my word",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/coje67XoytKsXMYqF)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 3333,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.00392156862745098,
    0.11372549019607843,
    0.3411764705882353,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 67,
    "ORIGINAL_DATE": {
      "$date": 1642066937459
    }
  }
}*/



#define PI radians(180.)
#define NUM_SEGMENTS 1.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.93
void main() {
    float T = cos( time*mod(floor(vertexId / 2.0) * -mod(vertexId, 2.0) * STEP, NUM_SEGMENTS));
float snd = texture(sound,vec2(0.,1.)).r;
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float offset = count * sin(time * .6- mouse.y) + 11.0;
  float angle = point * PI * 3.0 / NUM_SEGMENTS + offset;
  float radius = pow(count * 0.0014, 1.0);
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = pow(count * 0.0000025, .9);
  float innerRadius = pow(count * 0.0003, .2);
  float oC = cos(orbitAngle + count * 0.005) * innerRadius*mouse.y*sin(time);
  float oS = sin(orbitAngle + count * 0.01) * innerRadius-mouse.x+sin(time);

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC -1.+ c+oS,
      oS + s+c);
  gl_Position = vec4(xy * aspect * .60161, sin(time), 1);

  float b = 0.2 *sin(time-1.)/ pow(sin(count *1.4+T) * 1.3 + 0.17, 1.8);
  b = 0.20;mix(-.3, mouse.x/0.9, b)/-T;
  v_color = vec4(c,- snd/c, cos(T*snd-snd*b)+b/c-b, .489);
}
