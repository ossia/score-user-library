/*{
  "DESCRIPTION": "ping",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/pJM2rdtSkSBnEkMeG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 92244,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 215,
    "ORIGINAL_DATE": {
      "$date": 1448536474385
    }
  }
}*/

/*

  _ _ _____ __ __ _______ _____ __ __ ______ __ __ _____ _____ _____ __ __ _____ __ __ _______
 /_/\ /\_\ /\_____\/_/\__/\ /\_______)\ /\_____\/\ /\ /\/ ____/\ /\_\ /_/\ /\___/\ /\ __/\ /\_____\/_/\__/\ /\___/\ /_/\__/\ /\_______)\
 ) ) ) ( (( (_____/) ) ) ) )\(___ __\/( (_____/\ \ \/ / /) ) __\/( ( (_) ) ) / / _ \ \ ) ) \ \( (_____/) ) ) ) ) / / _ \ \ ) ) ) ) )\(___ __\/
/_/ / \ \_\\ \__\ /_/ /_/_/ / / / \ \__\ \ \ / / \ \ \ \ \___/ / \ \(_)/ // / /\ \ \\ \__\ /_/ /_/_/ \ \(_)/ //_/ /_/_/ / / /
\ \ \_/ / // /__/_\ \ \ \ \ ( ( ( / /__/_ / / \ \ _\ \ \ / / _ \ \ / / _ \ \\ \ \/ / // /__/_\ \ \ \ \ / / _ \ \\ \ \ \ \ ( ( (
 \ \ / /( (_____\)_) ) \ \ \ \ \ ( (_____\/ / /\ \ \)____) )( (_( )_) )( (_( )_) )) )__/ /( (_____\)_) ) \ \( (_( )_) ))_) ) \ \ \ \ \
  \_\_/_/ \/_____/\_\/ \_\/ /_/_/ \/_____/\/__\/__\/\____\/ \/_/ \_\/ \/_/ \_\/ \/___\/ \/_____/\_\/ \_\/ \/_/ \_\/ \_\/ \_\/ /_/_/

*/

#define PI radians(180.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat4 rotY( float angle ) {
    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 1);
}

mat4 rotZ( float angle ) {
    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1);
}

mat4 trans(vec3 trans) {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    trans, 1);
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
    0, 0, 0, 1);
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
  return v * 0.5 + 0.5;
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
  float ux = floor(edgeId / 6.) + mod(edgeId, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  float sub = floor(id / NUM_POINTS_PER_DIVISION);
  float subV = sub / (NUM_SUBDIVISIONS_PER_CIRCLE - 1.);
  float level = subV + vy / (NUM_SUBDIVISIONS_PER_CIRCLE - 1.);
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float v = mix(inner, 1., level);
  float a = mix(start, end, u) * PI * 2. + PI * 0.0;
  float s = sin(a);
  float c = cos(a);
  float x = c * v;
  float y = s * v;
  float z = 0.;
  pos = vec3(x, y, z);
  uv = vec2(floor(edgeId / 6.) / NUM_EDGE_POINTS_PER_CIRCLE, subV);
}

float goop(float t) {
  return sin(t) + sin(t * 0.27) + sin(t * 0.13) + sin(t * 0.73);
}

void main() {
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
  float pointId = mod(vertexId, NUM_POINTS_PER_CIRCLE);
// float sideId = floor(circleId / 2.);
// float side = mix(-1., 1., step(0.5, mod(circleId, 2.)));
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float cu = circleId / numCircles;
  vec3 pos;
  float inner = mix(0.5, 0.5, p1m1(sin(goop(circleId) + time * 0.1)));
  float start = fract(hash(circleId * 0.33) + sin(time * 0.03 + circleId) * 1.1);
  float end = start + 1.;//start + hash(sideId + 1.);
  vec2 uv;
  getCirclePoint(pointId, inner, start, end, pos, uv);

  float snd = texture(sound, vec2((0.02 + cu + abs(uv.x * 2. - 1.)) * 0.20, uv.y * 0.05)).r;

  vec3 offset = vec3(m1p1(hash(circleId)) * 0.5, m1p1(hash(circleId * 0.37)), -m1p1(circleId / numCircles));
  offset.x += goop(circleId + time * 0.3) * 0.4;
  offset.y += goop(circleId + time * 0.13) * 0.1;
  vec3 aspect = vec3(1, resolution.x / resolution.y, 1);

  mat4 mat = ident();
  mat *= scale(aspect);
  mat *= trans(offset);
  mat *= uniformScale(mix(0.1, 0.4, hash(circleId) * exp(snd)));
  gl_Position = vec4((mat * vec4(pos, 1)).xyz, 1);
  gl_PointSize = 4.;

  float hue = mix(mix(0.6, 0.7, fract(circleId * 0.79)), 1., step(0.75, snd));
  float sat = 1.;
  float val = 1.;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), pow(snd + 0.1, 5.));
  v_color = vec4(v_color.rgb * v_color.a, v_color.a);
}