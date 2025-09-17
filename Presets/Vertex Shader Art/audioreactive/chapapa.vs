/*{
  "DESCRIPTION": "chapapa",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/5fBJ6mEfnhkJuSFyR)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 98310,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    1,
    0.6313725490196078,
    0.43137254901960786,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 107,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1451064977413
    }
  }
}*/

/*

 ▌ ▐·▄▄▄ .▄▄▄ ▄▄▄▄▄▄▄▄ .▐▄• ▄ .▄▄ · ▄ .▄ ▄▄▄· ·▄▄▄▄ ▄▄▄ .▄▄▄ ▄▄▄· ▄▄▄ ▄▄▄▄▄
▪█·█▌▀▄.▀·▀▄ █·•██ ▀▄.▀· █▌█▌▪▐█ ▀. ██▪▐█▐█ ▀█ ██▪ ██ ▀▄.▀·▀▄ █·▐█ ▀█ ▀▄ █·•██
▐█▐█•▐▀▀▪▄▐▀▀▄ ▐█.▪▐▀▀▪▄ ·██· ▄▀▀▀█▄██▀▐█▄█▀▀█ ▐█· ▐█▌▐▀▀▪▄▐▀▀▄ ▄█▀▀█ ▐▀▀▄ ▐█.▪
 ███ ▐█▄▄▌▐█•█▌ ▐█▌·▐█▄▄▌▪▐█·█▌▐█▄▪▐███▌▐▀▐█ ▪▐▌██. ██ ▐█▄▄▌▐█•█▌▐█ ▪▐▌▐█•█▌ ▐█▌·
. ▀ ▀▀▀ .▀ ▀ ▀▀▀ ▀▀▀ •▀▀ ▀▀ ▀▀▀▀ ▀▀▀ · ▀ ▀ ▀▀▀▀▀• ▀▀▀ .▀ ▀ ▀ ▀ .▀ ▀ ▀▀▀

*/

#define PI radians(180.)

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

float inv(float v) {
  return 1. - v;
}

#define QUADS_PER_LINE 64.
#define SUBDIVISIONS_PER_QUAD 16.
#define POINTS_PER_LINE (QUADS_PER_LINE * SUBDIVISIONS_PER_QUAD * 6.)
const float tension = 0.5;

vec2 funky(const float id) {
  float v = id / QUADS_PER_LINE * 4.;
  float t = time;
  vec2 p = vec2(
    (sin(v + t) * 0.5 + sin(v * .37 + t) * 0.5 + sin(v * 2.951 + t)) / 3.,
    (cos(v * 9.12 + t) * 0.5 + cos(v * .37 + t) + cos(v * 2.951 + t)) / 3.
    );
  p.x *= 0.2;
  return p;
}

vec3 getCenterPoint(const float id) {
  vec4 t = vec4(0);
  t.xy = funky(id);
  //t.x = id / QUADS_PER_LINE;
  //t.y = 0.;
  return vec3(t.x, t.y, 0);
}

vec3 getCurvePoint(const float superId) {
  float quadId = floor(superId / SUBDIVISIONS_PER_QUAD);
  float subId = mod(superId, SUBDIVISIONS_PER_QUAD);
  float subV = subId / SUBDIVISIONS_PER_QUAD;
  vec3 q0 = getCenterPoint(quadId - 1.);
  vec3 q1 = getCenterPoint(quadId + 0.);
  vec3 q2 = getCenterPoint(quadId + 1.);
  vec3 q3 = getCenterPoint(quadId + 2.);
  vec3 q4 = getCenterPoint(quadId + 3.);
  vec3 q5 = getCenterPoint(quadId + 4.);

  float s2 = pow(subV, 2.);
  float s3 = pow(subV, 3.);

  float c1 = 2. * s3 - 3. * s2 + 1.;
  float c2 = -(2. * s3) + 3. * s2;
  float c3 = s3 - 2. * s2 + subV;
  float c4 = s3 - s2;

  vec3 t1 = (q2 - q0) * tension;
  vec3 t2 = (q3 - q1) * tension;
  return c1 * q1 + c2 * q2 + c3 * t1 + c4 * t2;
}

void getQuadPoint(const float cpId, const float pointId, float thickness, vec2 seed, out vec3 pos, out vec2 uv) {
  float subId = mod(cpId, SUBDIVISIONS_PER_QUAD);
  float subV = subId / SUBDIVISIONS_PER_QUAD;

  vec3 q0 = getCurvePoint(cpId + 0.);
  vec3 q1 = getCurvePoint(cpId + 1.);
  vec3 q2 = getCurvePoint(cpId + 2.);
  vec3 q3 = getCurvePoint(cpId + 3.);
  vec3 q4 = getCurvePoint(cpId + 4.);
  vec3 q5 = getCurvePoint(cpId + 5.);

  float id = pointId;
  float ux = mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx

  #if 0
  vec3 p0 = mix(mix(q0, q1, subV), mix(q1, q2, subV), subV);
  vec3 p1 = mix(mix(q1, q2, subV), mix(q2, q3, subV), subV);
  vec3 p2 = mix(mix(q2, q3, subV), mix(q3, q4, subV), subV);
  vec3 p3 = mix(mix(q3, q4, subV), mix(q4, q5, subV), subV);
  vec3 perp0 = normalize(p2 - p0).yxz * vec3(-1, 1, 0) * thickness;
  vec3 perp1 = normalize(p3 - p1).yxz * vec3(-1, 1, 0) * thickness;
  pos = vec3(mix(p1, p2, vy) + mix(-1., 1., ux) * mix(perp0, perp1, vy));
  #else
  vec3 perp0 = normalize(q2 - q0).yxz * vec3(-1, 1, 0) * thickness;
  vec3 perp1 = normalize(q3 - q1).yxz * vec3(-1, 1, 0) * thickness;
  pos = vec3(mix(q1, q2, vy) + mix(-1., 1., ux) * mix(perp0, perp1, vy));
  #endif

  uv = vec2(ux, vy);
}

vec3 getQPoint(const float id) {
  float outId = mix(id, 8. - id, step(2.5, id));
  float ux = floor(outId / 6.) + mod(outId, 2.);
  float vy = mod(floor(outId / 2.) + floor(outId / 3.), 2.);
  vec3 pos = vec3(ux, vy, 0);
  return pos;
}

void main() {
  float vId = vertexId;
  if (vId < 6.) {
    gl_Position = vec4(getQPoint(vId).xy * 2. - 1., 0.99, 1);
    v_color = vec4(hsv2rgb(0.5 + vec3(time * 0.05, 1, 1)), 1.);
    return;

  }
  vId -= 6.;
  float lineId = floor(vId / POINTS_PER_LINE);
  float quadCount = POINTS_PER_LINE / 6.;
  float pointId = mod(vId, 6.);
  float quadId = floor(mod(vId, POINTS_PER_LINE) / 6.);
  float quadV = quadId / quadCount;
  float invQuadV = inv(quadV);
  vec3 pos;
  vec2 uv;

  float snd0 = texture(sound, vec2(fract(quadV * 0.5) * .05, quadV * 0.)).r;
  float snd1 = texture(sound, vec2(0.14, quadV * 0.15)).r;

  getQuadPoint(quadId, pointId, mix(0.025, 0.30, pow(snd0 + 0.0, 15.)), vec2(0), pos, uv);
  pos.z = quadV;

  mat4 mat = ident();

  mat *= rotZ(sin(time * 0.4 + quadId * 0.003) + lineId * PI * 0.25);
  mat *= scale(vec3(
    mix(1., -1., step(7.5, lineId)),
    resolution.x / resolution.y,
    1));

  gl_Position = vec4((mat * vec4(pos, 1)).xyz, 1);
  gl_PointSize = 4.;

  float hue = mix(0.95, 1.25, snd1) + time * 0.05;
  float sat = 1.;
  hue += mix(1.05, 0.0, step(10., mod(quadId, 20.)));
  float val = mix(1., 0.0, step(35., mod(quadId, 50.)));
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);//invQuadV);
  //v_color.a = mix(1.0, 0.5, step(50., mod(quadId, 100.)));
  v_color = vec4(v_color.rgb * v_color.a, v_color.a);

}

