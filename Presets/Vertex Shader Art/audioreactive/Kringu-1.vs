/*{
  "DESCRIPTION": "Kringu",
  "CREDIT": "kolargon (ported from https://www.vertexshaderart.com/art/YbA3f6xnjbmXzkwHx)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 40000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 364,
    "ORIGINAL_LIKES": 3,
    "ORIGINAL_DATE": {
      "$date": 1503981621743
    }
  }
}*/

/*

┬ ┬┌─┐┬─┐┌┬┐┌─┐─┐ ┬┌─┐┬ ┬┌─┐┌┬┐┌─┐┬─┐┌─┐┬─┐┌┬┐
└┐┌┘├┤ ├┬┘ │ ├┤ ┌┴┬┘└─┐├─┤├─┤ ││├┤ ├┬┘├─┤├┬┘ │
 └┘ └─┘┴└─ ┴ └─┘┴ └─└─┘┴ ┴┴ ┴─┴┘└─┘┴└─┴ ┴┴└─ ┴

inspired by:
http://codepen.io/xposedbones/full/aOrQVy

*/

//KDrawmode=GL_TRIANGLES
//KVerticesNumber=40000
//KBackGroundColor=vec3(0.,0.,0.);

//for the K Machine
#define parameter0 0.//KParameter0 0.>>30.
#define parameter1 1.1//KParameter1 0.>>1.
#define parameter2 0.1//KParameter2 0.>>1.
#define parameter3 0.5//KParameter3 0.>>0.5
#define parameter4 0.//KParameter4 0.>>1.
#define parameter5 0.//KParameter5 0.>>1.
#define parameter6 0.//KParameter6 0.>>1.

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
//#define NUM_SUBDIVISIONS_PER_CIRCLE 16.
#define NUM_POINTS_PER_DIVISION (NUM_EDGE_POINTS_PER_CIRCLE * 6.)
#define NUM_POINTS_PER_CIRCLE (NUM_SUBDIVISIONS_PER_CIRCLE * NUM_POINTS_PER_DIVISION)
void getCirclePoint(const float id, const float inner, const float start, const float end, out vec3 pos, out vec4 uvf, out float snd) {
  float NUM_SUBDIVISIONS_PER_CIRCLE = floor(vertexCount / NUM_POINTS_PER_DIVISION);
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
  float su = fract(abs(u * 2. - 1.) + time * 0.1);
  //snd = texture(sound, vec2(0.02 + su * 0.10, (1. - ringV) * 0.1)).r;
  snd = 1.;
  float ss = 0.8;//mix(0.0, 1.0, pow(snd, 1.0));

  a += 1. / NUM_EDGE_POINTS_PER_CIRCLE * PI * 2. * 20. * sin(time * 1.) + snd * 7.5;
  float s = sin(a);
  float c = cos(a);
  float z = mix(inner, 2., level) - vy / NUM_SUBDIVISIONS_PER_CIRCLE * 0.1;
  float x = c * v * z * ss;
  float y = s * v * z * ss;
  pos = vec3(x, y, 0.);
  uvf = vec4(floor(edgeId / 6.) / NUM_EDGE_POINTS_PER_CIRCLE, subV, floor(id / 6.), level);
}

void main() {
  float NUM_SUBDIVISIONS_PER_CIRCLE = floor(vertexCount/2. / NUM_POINTS_PER_DIVISION);
  float fVertexId = mod(vertexId,vertexCount/2.);
  float circleId = floor(fVertexId / NUM_POINTS_PER_CIRCLE);
  float pointId = mod(fVertexId, NUM_POINTS_PER_CIRCLE);
  float sideId = floor(circleId / 2.);
  float side = mix(-1., 1., step(0.15, mod(circleId, 2.)));
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float cu = circleId / numCircles;
  vec3 pos;
  float inner = parameter3;
  float start = 0.0;
  float end = start + parameter2;
  float snd;
  vec4 uvfl;
  getCirclePoint(pointId, inner, start, end, pos, uvfl, snd);

  mat4 mat = scale(vec3(resolution.y / resolution.x, 1.91, 0.8) * .04 - min(resolution.x / resolution.y, 1.7));
  mat *= rotZ((parameter0 + uvfl.y * PI) * time * parameter1);

  /*
  if(vertexId>vertexCount/2.)
    pos.x += 0.5;
  */
  if(vertexId>vertexCount/2.)
    pos.x += (0.5-pos.x);
  gl_Position = mat * vec4(pos, 1);
  gl_PointSize = 4.;

  v_color = vec4(parameter4,parameter5, parameter6, 1.);
// v_color = mix(v_color.rgba, vec4(1,1,1,1), mod(uvf.z, 2.));
// v_color.a = 1.0 - uvf.y;
// v_color = vec4(v_color.rgb * v_color.a, v_color.a);
}