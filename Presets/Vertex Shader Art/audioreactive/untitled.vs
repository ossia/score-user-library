/*{
  "DESCRIPTION": "\u2601",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/j83YWD4DHLXrjrvxf)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 73728,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.9921568627450981,
    0.984313725490196,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 158,
    "ORIGINAL_DATE": {
      "$date": 1448993319729
    }
  }
}*/

/*

┬ ┬┌─┐┬─┐┌┬┐┌─┐─┐ ┬┌─┐┬ ┬┌─┐┌┬┐┌─┐┬─┐┌─┐┬─┐┌┬┐
└┐┌┘├┤ ├┬┘ │ ├┤ ┌┴┬┘└─┐├─┤├─┤ ││├┤ ├┬┘├─┤├┬┘ │
 └┘ └─┘┴└─ ┴ └─┘┴ └─└─┘┴ ┴┴ ┴─┴┘└─┘┴└─┴ ┴┴└─ ┴

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

mat4 persp(float fov, float aspect, float zNear, float zFar) {
  float f = tan(PI * 0.5 - 0.5 * fov);
  float rangeInv = 1.0 / (zNear - zFar);

  return mat4(
    f / aspect, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (zNear + zFar) * rangeInv, -1,
    0, 0, zNear * zFar * rangeInv * 2., 0);
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
#define NUM_SUBDIVISIONS_PER_CIRCLE 256.
#define NUM_POINTS_PER_DIVISION (NUM_EDGE_POINTS_PER_CIRCLE * 6.)
#define NUM_POINTS_PER_CIRCLE (NUM_SUBDIVISIONS_PER_CIRCLE * NUM_POINTS_PER_DIVISION)
void getCirclePoint(const float id, const float inner, const float start, const float end, out vec3 pos, out vec3 uvf, out float snd) {
  float edgeId = mod(id, NUM_POINTS_PER_DIVISION);
  float ux = floor(edgeId / 6.) + mod(edgeId, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  float sub = floor(id / NUM_POINTS_PER_DIVISION);
  float subV = sub / (NUM_SUBDIVISIONS_PER_CIRCLE - 1.);
  float level = subV + vy / (NUM_SUBDIVISIONS_PER_CIRCLE - 1.);
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float v = 1.;//mix(inner, 1., level);
  float ringId = sub + vy;
  float ringV = ringId / NUM_SUBDIVISIONS_PER_CIRCLE;
  float a = mix(start, end, u) * PI * 2. + PI * 0.0;
  float skew = 1. - step(0.5, mod(ringId - 2., 3.));
  snd = texture(sound, vec2((0.02 + abs(u * 2. - 1.)) * 0.20, 1. -ringV)).r;

  a += 1. / NUM_EDGE_POINTS_PER_CIRCLE * PI * 2. * 2. * time * 1. + snd * 1.5;
  float s = sin(a);
  float c = cos(a);
  float x = c * v;
  float y = s * v;
  float z = mix(inner, 1., level);
  pos = vec3(x, y, z);
  uvf = vec3(floor(edgeId / 6.) / NUM_EDGE_POINTS_PER_CIRCLE, subV, floor(id / 6.));
}

float goop(float t) {
  return sin(t) + sin(t * 0.27) + sin(t * 0.13) + sin(t * 0.73);
}

void main() {
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
  float pointId = mod(vertexId, NUM_POINTS_PER_CIRCLE);
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float cu = circleId / numCircles;
  vec3 pos;
  float inner = 0.5;
  float start = 0.;//time * -0.1;
  float end = start + 1.;
  float snd;
  vec3 uvf;
  getCirclePoint(pointId, inner, start, end, pos, uvf, snd);

  vec3 offset = vec3(0);
  offset.z += 40.;

  mat4 mat = ident();
  mat *= persp(radians(65.), resolution.x / resolution.y, 0.1, 100.);
  mat *= trans(offset);
  mat *= scale(vec3(0.25, 0.25, -80.));
  gl_Position = mat * vec4(pos, 1);
  gl_PointSize = 4.;

  float th = texture(sound, vec2(0.018 / 4., 0.0)).r;

  float h = sin(time * 0.1) + 0.4;
  float hue = mix(h, h + .1, snd);
  float sat = 0.2;
  float val = mix(.065, 1., snd);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
  v_color.a = 1.0 - uvf.y;
  v_color = vec4(v_color.rgb * v_color.a, v_color.a);
  v_color.rgb = mix(v_color.rgb, 1. - v_color.rgb, step(0.95, th));//pow(th, 10.));
}