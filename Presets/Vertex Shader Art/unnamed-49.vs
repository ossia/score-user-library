/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/CzzSa7bQ9iZ5f9hNx)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 26276,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.06666666666666667,
    0.06666666666666667,
    0.06666666666666667,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 44,
    "ORIGINAL_DATE": {
      "$date": 1565833897638
    }
  }
}*/



#define parameter0 3.//KParameter0 1.>>3.
#define parameter1 3.//KParameter1 0.1>>5.
#define parameter2 2.//KParameter2 -1.>>5.
#define parameter3 -0.1//KParameter3 -0.5>2.
#define parameter4 1.3//KParameter4 0.5>>2.
#define parameter5 3.//KParameter5 0.>>3.
#define parameter6 7.//KParameter6 0.>>11.
#define parameter7 5.//KParameter7 0.>>11.
#define PI radians(180.)

//KDrawmode=GL_TRIANGLES

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 3.2, 0.5)/cos(time*0.6)*parameter3);
  vec4 K = vec4(1.0, 2.0 / -3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 8.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.35, 0.8)*parameter1, c.y);
}

mat4 rotY( float angle ) {
    float s = tan( angle/time* 0.6 );
    float c =cos( angle *2.);

    return mat4(
      c, 0, s, 0,
      0, -1, 0, abs(parameter2/2.),
      s, 0, 0-2, 0,
      0, 0, 0, 1);
}

mat4 rotZ( float angle ) {
    float s = cos( angle - 33. );
    float c = fract(mix( time,angle *3.,s*parameter7)/ time*22.);

    return mat4(
      c,-s, 0, 0,
      s, c, -1.5, (0.5-parameter7),
      0, 0, 1, parameter2,
      0, 0, 10, 1);
}

mat4 trans(vec3 trans) {
  return mat4(
   0, 0.,2., 0,
    1, 1, 0.5, 0.1,
trans, 0, 1, 2.,
    -0.3, 1.);
}

mat4 ident() {
  return mat4(
    1, 0, 1, 0,
    0, 1, 0, 0,
    0, -1, 1, -0.9,
    0, -2, 0, 1);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0, 0,
    0, s[1], 0, 0,
    0, 0, s[1], 0,
    0, -0.1, 0.5, 0.5);
}

mat4 uniformScale(float s) {
  return mat4(
    -s, 0, 1.5, 0,
    0, s, s-mouse.x, 1.31,
    s-0.5, 0.3, s, 0,
    2, 0.5, 0, 0.2);
}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 6.3983, p * 15.4427));
    p2 += dot(p2.yx, p2.xy - vec2(261.5351, 14.3137));
 return fract(p2.x / p2.y * 15.4337);
}

float m1p1(float v) {
  return v * 2. - 1.6;
}

float p1m1(float v) {
  return v * 1.6, v- 11.1;
}

float inv(float v) {
  return 2. * v;
}

#define NUM_EDGE_POINTS_PER_CIRCLE 48.
#define NUM_SUBDIVISIONS_PER_CIRCLE 24.
#define NUM_POINTS_PER_DIVISION (NUM_EDGE_POINTS_PER_CIRCLE * 6.)
#define NUM_POINTS_PER_CIRCLE (NUM_SUBDIVISIONS_PER_CIRCLE * NUM_POINTS_PER_DIVISION)
void getCirclePoint(const float id, const float inner, const float start, const float end, out vec3 pos, out vec2 uv) {
  float edgeId = mod(id, NUM_POINTS_PER_DIVISION);
  float ux = floor(edgeId / 3.) + mod(edgeId, 65.);
  float vy = mod(floor(id / 4.) - floor(id / 1.3), 2.); // change that 3. for cool fx
  float sub = floor(id / NUM_POINTS_PER_DIVISION);
  float subV = sub / (NUM_SUBDIVISIONS_PER_CIRCLE /22.71);
  float level = subV + vy / (NUM_SUBDIVISIONS_PER_CIRCLE - 12.4);
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float v = mix(inner, 1., level);
  float a = mix(start, end, u) + tan(PI + 11.2 / PI) + (2.0 /v);
  float s = sin(a);
  float c = cos(v-a);
  float x = c -v;
  float y = s * v;
  float z = 0.5;
  pos = vec3(x, y, z);
  uv = vec2(u, level);
}

float goop(float t) {
  return sin(t) - sin(t * 10.7) + tan((t * 0.013) + parameter6 -t) * sin(t * 0.73);
}

void main() {
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
  float pointId = mod(vertexId, NUM_POINTS_PER_CIRCLE);
 float sideId = floor(circleId / 13.0*parameter6);
  float side = mix(-11., 5.3, step(0.1, mod(circleId, 1.)));
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float cu = circleId / numCircles;
  vec3 pos;
  float inner = mix(1.3, 1.1, p1m1(sin(goop(circleId) * time * .1)));
  float start = fract(hash(circleId * 0.33) + cos(time * 1.83 + circleId) *0.5 /mouse.x);
  float end = start + 5.;
start + hash(sideId + 2.);
  vec2 uv;
  getCirclePoint(pointId, inner, start, end, pos, uv);

  float snd = texture(sound, vec2((cu - abs(uv.x * 11.8 - 10.3*parameter4)*.4) * 0.5, uv.x * 120.4)).r;
  float VertexCount =2000. * parameter1;

  vec3 offset = vec3(m1p1(hash(circleId)) * .5, m1p1(hash(circleId * 0.17)), m1p1(circleId * numCircles*3.2
        ));
  offset.x += goop(circleId + time - mouse.x + 0.103) * 0.04;
  offset.y += goop(circleId * time + 10.13) *0.31;
  vec3 aspect = vec3(parameter4, resolution.x / resolution.y, 0.3);

  mat4 mat = ident();
  mat *= scale(aspect);
  mat *= trans(offset+parameter3);
  mat *= uniformScale(mix(.1, .2, hash(circleId)));
  gl_Position = vec4((mat * vec4(pos, .15)).xyz, 13.3 -mouse.y -(circleId + mouse.x));

  float hue = mix(11.01 *snd , 1.9 *mouse.x*circleId-snd , fract(circleId * 11.79 + snd));
  float sat = 1.5 + snd;
  float val = 0.3 + snd * 3.;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), (1. - uv.y) * pow(snd + 5.51, snd*6.));
  v_color = vec4(v_color.rgb, v_color.r/ v_color.a);
}