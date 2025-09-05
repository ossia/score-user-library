/*{
  "DESCRIPTION": "sput",
  "CREDIT": "macro (ported from https://www.vertexshaderart.com/art/STvAdbbowvRQ7XfSb)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 30720,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    1,
    0.14901960784313725,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1600427127635
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

#define NUM_EDGE_POINTS_PER_CIRCLE 256.
#define NUM_SUBDIVISIONS_PER_CIRCLE 2.
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
  float edgeId = mod(vertexId, NUM_POINTS_PER_DIVISION);
  float ux = floor(edgeId / 6.) + mod(edgeId, 2.);
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float u2 = floor(edgeId / 6.) / NUM_EDGE_POINTS_PER_CIRCLE;
  float snd = texture(sound, vec2(mix(0.0, 0.25, hash(u2)), 0.0)).r;
  float inner = mix(0.5, 1.0, pow(snd + .3, 5.0));//0.9; //mix(0.0, 0.5, p1m1(sin(goop(circleId) + time * 0.1)));
  float start = fract(hash(circleId * 0.33));
  float end = start + 1.;//start + hash(sideId + 1.);
  vec2 uv;
  getCirclePoint(pointId, inner, start, end, pos, uv);

  vec3 offset = vec3(m1p1(hash(circleId * floor(time * 1.2) * 0.123)), m1p1(hash(circleId * 0.37)), -m1p1(circleId / numCircles));
  //offset = vec3(0);
  vec3 aspect = vec3(1, resolution.x / resolution.y, 1);

  mat4 mat = ident();
  mat *= scale(aspect);
  mat *= trans(offset);
  mat *= uniformScale(mix(0.2, 0.3, pow(snd, 1.)));
  gl_Position = vec4((mat * vec4(pos, 1)).xyz, 1);
  gl_PointSize = 4.;

  vec3 cc = mix(vec3(1), vec3(0), mod(circleId, 2.0));
  vec3 fl = mix(vec3(0,1,1), vec3(.5,1,1), mod(time * 60.0, 2.0));
  vec3 c2 = mix(cc, fl, step(0.8, snd));
  float hue = fract(circleId);//, 1., step(0.75, snd));
  float sat = step(0.5, snd);
  float val = mod(circleId, 2.);step(0.50, snd);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1.);
  v_color.rgb = c2;
  v_color = vec4(v_color.rgb * v_color.a, v_color.a);
}//sss