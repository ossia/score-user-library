/*{
  "DESCRIPTION": "luv",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/PmW7c9NeLghdwa8S4)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 454,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1451676484911
    }
  }
}*/

/*

        .
     .-. ...;....;. _
_.; : .-. .;.::..'.-. `.,' '
 ; ;.;.-' .; .;.;.-' ,'`.
 `._.' `:::'.;' .; `:::' -' `._.
        .; .'
     . ;;-. .-. .-..' .-. .;.::.
   .'; ;; ;; : : ; .;.-' .;
 .' .'.;` ``:::'-'`:::'`.`:::'.;'
' .
        ...;...
   .-. .;.::..'
  ; : .; .;
  `:::'-'.;' .;

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

float p1m1(float v) {
  return v * 0.5 + 0.5;
}

float inv(float v) {
  return 1. - v;
}

#define NUM_EDGE_POINTS_PER_CIRCLE 48.
#define NUM_POINTS_PER_CIRCLE (NUM_EDGE_POINTS_PER_CIRCLE * 6.)
void getCirclePoint(const float id, const float inner, const float start, const float end, out vec3 pos) {
  float outId = id - floor(id / 3.) * 2. - 1.; // 0 1 2 3 4 5 6 7 8 .. 0 1 2, 1 2 3, 2 3 4
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float v = mix(inner, 1., vy);
  float a = mix(start, end, u) * PI * 2. + PI * 0.0;
  float r = pow(cos((u - 0.5) * 2.), 2.);
  float s = sin(a) * abs(cos(a * 0.5));
  float c = cos(a);
  float x = c * v * r;
  float y = s * v * r;
  float z = 0.;
  pos = vec3(x, y, z);
}

float goop(float t) {
  return sin(t) + sin(t * 0.27) + sin(t * 0.13) + sin(t * 0.73);
}

const float numTrails = 1.;
void main() {
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
// float trailId = mod(circleId, numTrails);
// float trailV = trailId / numTrails;
// circleId = floor(circleId / trailId);
float trailV = 1.;
  float pointId = mod(vertexId, NUM_POINTS_PER_CIRCLE);
  float pointV = pointId / NUM_POINTS_PER_CIRCLE;
  float sliceId = mod(floor(vertexId / 6.), 2.);
  float side = mix(-1., 1., step(0.5, mod(circleId, 2.)));
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float cu = circleId / numCircles;
  vec3 pos;
  float inner = 0.;//mix(0.0, 1.0, p1m1(sin(goop(circleId) + time * 0.0)));
  float start = 0.0;//fract(hash(sideId * 0.33) + sin(time * 0.1 + sideId) * 1.1);
  float end = 1.; //start + hash(sideId + 1.);
  getCirclePoint(pointId, inner, start, end, pos);

  float across = floor(sqrt(numCircles));
  float down = floor(numCircles / across);
  float uId = mod(circleId, across);
  float u = uId / (across - 1.);
  float vId = floor(circleId / across);
  float v = vId / (down - 1.);

  float ur = m1p1(u);// * cos(time);
  float vr = m1p1(v);// * sin(time);
  float rr = length(vec2(ur, vr));
  float aa = (atan(ur, vr) + PI) / (2. * PI);
  float snd = texture(sound, vec2(abs(m1p1(aa)) * 0.0125, rr * .2)).r;

  vec3 offset = vec3(0);vec3(hash(circleId) * 0.8, m1p1(hash(circleId * 0.37)), 0);
  offset.x += 0.;m1p1(pow(snd, 20.0) + goop(circleId + time * 0.) * 0.1);
  offset.y += 0.;goop(circleId + time * 0.) * 0.1;
  float timeOff = m1p1(mod(time * 0.01 + (cu * 3.), 1.));
  offset.x += m1p1(u) + mod(vId, 2.) / across; //sin(timeOff * PI * 2.) * cu * 2.;
  offset.y += m1p1(v); //cos(timeOff * PI * 2.) * cu * 2.;
  offset.z = -m1p1(cu);//m1p1(hash(circleId * 0.641)) - trailV * 0.01;
  vec3 aspect = vec3(1, resolution.x / resolution.y, 1.);

  mat4 mat = ident();
  mat *= scale(aspect);
 // mat *= rotZ(hash(circleId * 0.543) * PI * 2.);
  mat *= trans(offset);
 // mat *= rotZ(hash(circleId * 0.234) * PI * 2. + time);
 // mat *= rotZ(PI * -1.5 + snd * 6.);
  mat *= rotZ(m1p1(aa) * PI - PI * 0.5 );
  mat *= uniformScale(mix(0.0, 0.2, /*hash(circleId) * */ pow(snd, 3.0)));
  gl_Position = vec4((mat * vec4(pos, 1)).xyz, 1);
  gl_PointSize = 4.;

  float hue = mix(0.9, 1.05, fract(circleId * 0.17 + snd));
  float sat = trailV; //mix(1., 0., step(0.99, pow(snd, 5.0)));
  float val = mix(0.8, 1.0, fract(circleId * 0.79));
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
  v_color.a = p1m1(offset.z);
  v_color.rgb *= v_color.a;
}