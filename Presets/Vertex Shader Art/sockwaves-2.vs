/*{
  "DESCRIPTION": "sockwaves",
  "CREDIT": "zug (ported from https://www.vertexshaderart.com/art/Qx9JCRsXfk5Ajh3t7)",
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
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 263,
    "ORIGINAL_LIKES": 3,
    "ORIGINAL_DATE": {
      "$date": 1590985009752
    }
  }
}*/

// 💙💙💙💙💙

#define KP0 sin((time*0.0000006))

// from: http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 rgb2hsv(vec3 c) {
  vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
  vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
  vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

  float d = q.x - min(q.w, q.y);
  float e = 1.0e-10;
  return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

#define PI radians(180.)

mat4 rotZ(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

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

vec2 getCirclePoint(float id, float numCircleSegments) {
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);

  float angle = ux / numCircleSegments * PI * (3.*mouse.y);
  float c = cos(angle);
  float s = sin(angle);

  float radius = mix(0.5, 0.1, vy
        *1.-mouse.y);
  float x = c * radius;
  float y = s * radius;

  return vec2(x*2., y+x);
}

void main() {
  float vertexCount = 100000. *abs(mouse.x);
  float numCircleSegments = 4.0;
  vec2 circleXY = getCirclePoint(vertexId, numCircleSegments);
  float numPointsPerCircle = numCircleSegments * 6.;

  float circleId = floor(vertexId / numPointsPerCircle);
  float numCircles = floor(vertexCount / numPointsPerCircle);

  float sliceId = floor(vertexId / 6.);
  float oddSlice = mod(sliceId, 2.);

  float down = sqrt(numCircles);
  float across = floor(numCircles / down);
  float x = mod(circleId, across);
  float y = floor(circleId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float su = abs(u - 0.5) * 2.;
  float sv = abs(v - 0.5) * 2.;

  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));

 const int spots = 2;
  float snd = 0.;
  float totalSnd = 0.;
  vec3 color = vec3(0);
  for (int sp = 0; sp < spots; ++sp) {
    float spf = float(sp + 11)*KP0;
    float spx = hash(spf * 7.123-KP0);
    float spy = hash(spf * 0.317)+sin(KP0);
    float sps = hash(spf * 3.411)-sin(mouse.y+0.5);

    float sds = distance(vec2(u, v), vec2(spx, spy));
    float invSds = pow(clamp(1. - sds, 0., 1.), 3.);
    totalSnd += invSds;
    snd += texture(sound, vec2(mix(0.001, 0.151, sps), sds * .9)).r *
      mix(0.95, 1.7, sps) * invSds;

    color = mix(color, hsv2rgb(vec3(sps, 1., 1.)), pow(invSds,2.));
  }
  snd /= totalSnd;

  float xoff = 0.;//sin(time + y * 0.2) * 0.1;
  float yoff = 0.;//sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  float sc = pow(snd, 5.0) * 0.9 + oddSlice * 0.1;
  float aspect = resolution.x / resolution.y;

  vec4 pos = vec4(circleXY, 0, 0.5);
  mat4 mat = ident();
  mat *= scale(vec3(1, aspect, 0.5));
  mat *= rotZ(time * 0.);
  mat *= trans(vec3(ux, vy, 0));
  mat *= uniformScale(0.2 * sc * 20. / across);
  mat *= rotZ(snd * 22. * sign(ux)+2.);

  gl_Position = mat * pos;

  float soff = 1.;//sin(time + x * y * .02) * 5.;

  float pump = step(0.7, snd);

  vec3 hsv = rgb2hsv(color);
  hsv.x = mix(0., 0.2, hsv.x) + time * 0.1 + pump * .33;
  hsv.z = mix(0.5, 1., pump);
  v_color = vec4(hsv2rgb(hsv), 1);;
  v_color.rgb *= v_color.a;
}

