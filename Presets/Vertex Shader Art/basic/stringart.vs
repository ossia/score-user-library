/*{
  "DESCRIPTION": "stringart",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/EgLk7JDok4GhxPeMH)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Abstract"
  ],
  "POINT_COUNT": 500,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 316,
    "ORIGINAL_DATE": {
      "$date": 1447519218787
    }
  }
}*/

#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0
#define NUM_LINES_DOWN 64.0
#define PI 3.141592653589793

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  vec4 offsets = vec4(
    sin(time),
    sin(time * .13) * PI * 2.,
    sin(time * .43) * .5 + 1.,
    cos(time * .17) * .5 + .5);

  vec4 centers = vec4(
    sin(time * .163) * .5,
    cos(time * .267) * .5,
    sin(time * .367) * .5,
    cos(time * .497) * .5);

  vec4 mult = vec4(
    1.,
    (sin(time * .1) * .5 + .5) * 3.,
    0.,
    0.);

  vec2 position = vec2(vertexId / vertexCount, mod(vertexId, 2.));
  vec2 offset = mix(offsets.xz, offsets.yw, position.y);
  float a = mult.x * position.x * PI * 2.0 + offset.x;//mix(u_offsets.x, u_offsets.y, a_position.y);
  float c = cos(a * mult.y);
  vec2 xy = vec2(
    cos(a),
    sin(a)) * c * offset.y +
    mix(centers.xy, centers.zw, position.y);
  vec2 aspect = vec2(resolution.y / resolution.x, 1);
  gl_Position = vec4(xy * aspect, 0, 1);

  float hue = position.x;
  float sat = 1.;
  float val = 1.;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}