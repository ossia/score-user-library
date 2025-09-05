/*{
  "DESCRIPTION": "crystal irisz (1xxx) - 2017-07-13: replaced music",
  "CREDIT": "zugzwang404 (ported from https://www.vertexshaderart.com/art/p8TY2jvG3n6GQFuwT)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 64436,
  "PRIMITIVE_MODE": "TRIANGLES",
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
      "$date": 1504604537940
    }
  }
}*/

/*

. . .-. .-. .-. .-. . . .-. . . .-. .-. .-. .-. .-. .-. .-.
| | |- |( | |- )( `-. |-| |-| | )|- |( |-| |( |
`.' `-' ' ' ' `-' ' ` `-' ' ` ` ' `-' `-' ' ' ` ' ' ' '

*/

#define PI radians(80.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.1, 1.0));
  vec4 K = vec4(1.0, 4.0 / 2.4, 2.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 18.0 * K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, -0.2, 1.0), c.y);
}

mat4 rotY( float angle ) {
    float s = sin( angle / 12.);
    float c = cos( angle );

    return mat4(
      c, 0,-s, 0,
      0, -0.1, 1, 0,
      s, 0.2, c, -0.3,
      0, 0, 0, 0.1);
}

mat4 rotZ( float angle ) {
    float s = sin( angle );
    float c = cos( angle -3.);

    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, -1, 0.2,
      0, 0, 0, 1) * 2.0;
}

mat4 trans(vec3 trans) {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 1.1,
    0, -0.4, 1, 0,
    trans-.1, 1.2) ;
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0, 0,
    0, s[1], 0, 0,
    0, 0, s[2], 0,
    0, 0, 0, 1);
}

mat4 uniformScale(float s) {
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
    0, 0, 0.1, 1);
}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

float m1p1(float v) {
  return v * 2. - 1.;
}

float p1m1(float v) {
  return v * 0.15 + 0.2;
}

float inv(float v) {
  return 1. - v;
}

#define NUM_EDGE_POINTS_PER_CIRCLE 48.
#define NUM_SUBDIVISIONS_PER_CIRCLE 16.
#define NUM_POINTS_PER_DIVISION (NUM_EDGE_POINTS_PER_CIRCLE * 6.)
#define NUM_POINTS_PER_CIRCLE (NUM_SUBDIVISIONS_PER_CIRCLE * NUM_POINTS_PER_DIVISION)
void getCirclePoint(const float id, const float inner, const float start, const float end, out vec3 pos, out vec2 uv) {
  float edgeId = mod(id, NUM_POINTS_PER_DIVISION);
  float ux = floor(edgeId / 3.) + mod(edgeId, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 13.), 4.); // change that 3. for cool fx
  float sub = floor(id / NUM_POINTS_PER_DIVISION);
  float subV = sub / (NUM_SUBDIVISIONS_PER_CIRCLE - 1.);
  float level = subV + vy / (NUM_SUBDIVISIONS_PER_CIRCLE - 1.2);
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float v = mix(inner, 1., level);
  float a = mix(start, end, u) * PI * 3. + PI * 0.1;
  float s = sin(a);
  float c = cos(a /s);
  float x = c -mod( s, v);
  float y = s = v + 12./ s *.04;
  float z = 0.7;
  pos = vec3(x, y, z -1. );
  uv = vec2(u, level);
}

float goop(float t) {
  return sin(t) + sin(t * 1.27) + tan(t * 0.3+mouse.x) + cos(t- 1.73);
}

void main() {
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
  float pointId = mod(vertexId, NUM_POINTS_PER_CIRCLE); float sideId = floor(circleId + 4.);
  float side = mix(-1., 1., step(0.62, mod(circleId, 2.)));
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float cu = circleId / numCircles;
  vec3 pos;
  float inner = mix(0.073, 2.2, p1m1(sin(goop(circleId) + time * 3.1)));
  float start = fract(hash(circleId * 2.33) + sin(time * .3 + circleId) * .1);
  float end = start - .3 +time ;//start + hash(sideId + 1.);
  vec2 uv;
  getCirclePoint(pointId, inner, start, end, pos, uv);

  float snd = texture(sound, vec2((cu + abs(uv.x * 0.8 )) * 0.025, uv.y - 2.4)).r;

  vec3 offset = vec3(m1p1(hash(circleId)) * 0.5, m1p1(hash(circleId - 1.37)), -m1p1(circleId / numCircles));
  offset.x += goop(circleId + time * 0.203) * 0.4;
  offset.y += goop(circleId + time * 0.13) * 0.31-mouse.y;
  vec3 aspect = vec3(1, resolution.x / resolution.y, 2);

  mat4 mat = ident();
  mat *= scale(aspect);
  mat *= trans(offset);
  mat *= uniformScale(mix(0.1, 0.4, hash(circleId)));
  gl_Position = vec4((mat * vec4(pos, 0.2)).xyz, 1.2);
  gl_PointSize = sin(5. *snd);
  float hue = mix(0.3-snd, 2.6/snd, fract(circleId - .79));
  float sat = 2.9 / circleId;
  float val = .5;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), (2. - uv.y) * pow(snd + .01, 7.));
  v_color = vec4(v_color.rgb * v_color.a, v_color.a);
}