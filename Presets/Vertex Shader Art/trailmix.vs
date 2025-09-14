/*{
  "DESCRIPTION": "trailmix",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/mM93aaccacmA9o34t)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 98304,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Touch", "NAME": "touch", "TYPE": "image" }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 206,
    "ORIGINAL_DATE": {
      "$date": 1448961631673
    }
  }
}*/

// ==========================================
// ^
// |
// +-- click "hide" then MOVE YOUR MOUSE!!!!
// ==========================================

#define PI 3.14159

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

#define QUADS_PER_LINE 256.
#define SUBDIVISIONS_PER_QUAD 16.
#define POINTS_PER_LINE (QUADS_PER_LINE * SUBDIVISIONS_PER_QUAD * 6.)
const float tension = 0.5;

vec3 getCenterPoint(const float id) {
  vec4 t = vec4(0);
  const int samples = 4;
  for (int ii = 0; ii < samples; ++ii) {
    t += texture(touch,
        vec2(0.,
        (id * 0.2) / (IMG_SIZE(sound).y * 1.)
        + float(ii) / float(samples) * 0.01));
  }
  t /= 4.;
  //t.xy = vec2(m1p1(hash(id)), m1p1(hash(id * 0.37))) * 0.5;
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

void main() {
  float lineId = floor(vertexId / POINTS_PER_LINE);
  float quadCount = POINTS_PER_LINE / 6.;
  float pointId = mod(vertexId, 6.);
  float quadId = floor(mod(vertexId, POINTS_PER_LINE) / 6.);
  float quadV = quadId / quadCount;
  float invQuadV = inv(quadV);
  vec3 pos;
  vec2 uv;

  float snd0 = texture(sound, vec2(0.03, quadV * 0.2)).r;
  float snd1 = 0.6;texture(sound, vec2(0.14 + lineId * 0.05, quadId / quadCount * 0.01)).r;

  getQuadPoint(quadId, pointId, mix(0.01, 0.25, pow(snd0 + 0.2, 15.)), vec2(pow(snd0, 2.), pow(snd1, 2.0)), pos, uv);

// vec3 aspect = vec3(resolution.y / resolution.x, 1, 1);

  mat4 mat = ident();
  mat *= scale(vec3(
    mix(1., -1., mod(lineId, 2.)),
    mix(1., -1., mod(floor(lineId / 2.), 2.)),
    1));
  gl_Position = vec4((mat * vec4(pos, 1)).xyz, 1);
// gl_Position.z = -m1p1(quadId / quadCount);
// gl_Position.x += m1p1(lineId / 10.) * 0.4 + (snd1 * snd0) * 0.1;
  gl_PointSize = 4.;

  float hue = mix(0.95, 1.95, snd0);
  float sat = 1.;
  float val = mix(1.0, 0.0, step(50., mod(quadId, 100.)));
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), invQuadV);
  v_color = vec4(v_color.rgb * v_color.a, v_color.a);

}

