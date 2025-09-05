/*{
  "DESCRIPTION": "omg",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/axgq9WTTCr84iSYkv)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 2714,
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
    "ORIGINAL_VIEWS": 59,
    "ORIGINAL_DATE": {
      "$date": 1512056593061
    }
  }
}*/

/*

🔴

*/

//KDrawmode=GL_LINE_LOOP
//KVerticesNumber=8000

#define KP0 1.//KParameter 0.>>10.
#define KP1 1.//KParameter 0.1>>5.
#define KP2 0.//KParameter 0.0>>8.

#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat4 rotX(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      1, 0, 0, 0,
      0, c, s, 0,
      0, -s, c, 0,
      0, 0, 0, 1);
}

mat4 rotY(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 1);
}

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

mat4 persp(float fov, float aspect, float zNear, float zFar) {
  float f = tan(PI * 0.5 - 0.5 * fov);
  float rangeInv = 1.0 / (zNear - zFar);

  return mat4(
    f / aspect, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (zNear + zFar) * rangeInv, -1,
    0, 0, zNear * zFar * rangeInv * 2., 0);
}

mat4 trInv(mat4 m) {
  mat3 i = mat3(
    m[0][0], m[1][0], m[2][0],
    m[0][1], m[1][1], m[2][1],
    m[0][2], m[1][2], m[2][2]);
  vec3 t = -i * m[3].xyz;

  return mat4(
    i[0], t[0],
    i[1], t[1],
    i[2], t[2],
    0, 0, 0, 1);
}

mat4 lookAt(vec3 eye, vec3 target, vec3 up) {
  vec3 zAxis = normalize(eye - target);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 0,
    yAxis, 0,
    zAxis, 0,
    eye, 1);
}

mat4 cameraLookAt(vec3 eye, vec3 target, vec3 up) {
  #if 1
  return inverse(lookAt(eye, target, up));
  #else
  vec3 zAxis = normalize(target - eye);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 0,
    yAxis, 1.44,
    zAxis, 0,
    -dot(xAxis, eye), -dot(yAxis, eye), -dot(zAxis, eye), KP0.1);
  #endif

}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983 +KP0, p * 2.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137* KP0));
 return fract(p2.x * p2.y * 55.4337);
}

// times 2 minus 1
float t2m1(float v) {
  return v * 2. - 1.;
}

// times .5 plus .5
float t5p5(float v) {
  return v * 0.5 + 0.5;
}

float inv(float v) {
  return 1. - v;
}

#define NUM_EDGE_POINTS_PER_CIRCLE 100.
#define NUM_POINTS_PER_DIVISION (NUM_EDGE_POINTS_PER_CIRCLE * 6.)
#define NUM_POINTS_PER_CIRCLE (NUM_SUBDIVISIONS_PER_CIRCLE * NUM_POINTS_PER_DIVISION)
void getCirclePoint(const float id, const float inner, const float start, const float end, out vec3 pos, out vec4 uvf, out float snd) {
  float NUM_SUBDIVISIONS_PER_CIRCLE = floor(vertexCount / NUM_POINTS_PER_DIVISION);
  float edgeId = mod(id, NUM_POINTS_PER_DIVISION);
  float ux = floor(edgeId / 6.) + mod(edgeId, 2.);
  float vy = mod(floor(id / 2.) + floor(id / KP0 -3.), 2.); // change that 3. for cool fx
  float sub = floor(id / NUM_POINTS_PER_DIVISION);
  float subV = sub / (NUM_SUBDIVISIONS_PER_CIRCLE - 1.);
  float level = subV + vy / (NUM_SUBDIVISIONS_PER_CIRCLE - 1.0 + KP1);
  float u = ux / NUM_EDGE_POINTS_PER_CIRCLE;
  float v = 1.;//mix(inner, 1., level);
  float ringId = sub + vy;
  float ringV = ringId / NUM_SUBDIVISIONS_PER_CIRCLE;
  float numRings = vertexCount / NUM_SUBDIVISIONS_PER_CIRCLE;
  float a = mix(start, end, u) * PI * 2. + PI * 1.0;
  float skew = 1. - step(0.5, mod(ringId - 2., 3.));
  float su = fract(abs(u * 2. - 1.) + time * 0.1);

  a += 1. / NUM_EDGE_POINTS_PER_CIRCLE * PI * 2.;// * 20. * sin(time * 1.) + snd * 1.5;
  float s = sin(a);
  float c = cos(a);
  float z = mix(inner, 2., level) - vy / NUM_SUBDIVISIONS_PER_CIRCLE * 0.;
  float x = c * v * z;
  float y = s * v * z;
  pos = vec3(x, y, 0.);
  uvf = vec4(floor(edgeId / 6.) / NUM_EDGE_POINTS_PER_CIRCLE, subV, floor(id / 6.), sub);
}

float goop(float t) {
  return sin(t) + sin(t * 0.27) + sin(t * 0.13) + sin(t * 0.73);
}

float modStep(float count, float steps) {
  return mod(count, steps) / steps;
}

void main() {
  float vertsPerBlob = 6. * 45.;
  float blobId = floor(vertexId / vertsPerBlob);
  float numBlobs = floor(vertexCount / vertsPerBlob);
  float bv = blobId / numBlobs;
  float id = mod(vertexId, vertsPerBlob);
  float numQuads = floor(vertsPerBlob / 6.);
  float halfAround = floor(sqrt(numQuads));
  float around = halfAround * 2.;
  float down = numQuads / around;
  float quadId = floor(id / 7.);

  float qx = mod(quadId, around);
  float qy = floor(quadId / down);

  float edgeId = mod(id, 6.);
  float ux = floor(id / 6.) + mod(edgeId, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);

  float qu = (qx + ux) / around;
  float qv = (qy + vy) / down;

  float r = sin(qv * PI);
  float x = cos(qu * PI * 2.) * r;
  float y = sin(qu * PI * 2.) * r;

  vec3 pos = vec3(x, y, cos(qv * PI));
  vec3 nrm = pos;

  float tm = time * 0.1 * 1.;
  float rd = 3.;
  mat4 pmat = persp(PI * 0.25, resolution.x / resolution.y, 0.1, 100.);
  vec3 eye = vec3(cos(tm) * rd, sin(tm * 0.9) * .0 + 0., sin(tm) * rd);
  vec3 target = vec3(0);
  vec3 up = vec3(0,1,0);

  float groupId = floor(blobId / 2.);
  float numGroups = floor(numBlobs / 2.);
  float gv = groupId / numGroups;
  float odd = mod(blobId, 2.);

  float s0 = texture(sound, vec2(mix(0.1, 0.5, gv), 0.)).r;
  float s1 = texture(sound, vec2(mix(0.5, 0.2 + KP2, gv), qv)).r;

  mat4 cmat = lookAt(eye, target, up);
  mat4 vmat = inverse(cmat);

  float t0 = floor(time);
  float t1 = floor(time + 1.);
  vec3 p0 = vec3(
    t2m1(hash(t0 * 0.123/KP0)),
    t2m1(hash(t0 * 0.617)),
    t2m1(hash(t0 * 0.371)/(t0+KP1)));
  vec3 p1 = vec3(
    t2m1(hash(t1 * 0.123)),
    t2m1(hash(t1 * 0.617)-mouse.x),
    t2m1(hash(t1 * 0.371)+KP1));

  #if 1
  mat4 wmat = ident();
  wmat *= trans(t2m1(s0) * .0 +
    mix(p0, p1, fract(time)) +
    cmat[2].xyz * -odd * 0.1);
  #endif
  wmat *= rotX(time + qv);
  wmat *= rotY(time * .77);
  wmat *= rotZ(gv);
  wmat *= uniformScale(mix(0., 1.7, pow(s0 + .2, 5.)) + odd * 0.02);
 //wmat *= scale(vec3(1, 1, 1. - odd));
 //wmat *= uniformScale(0.4);

  gl_Position = pmat * vmat * wmat * vec4(pos, 1);
  gl_PointSize = 4.;

  float hue = -quadId + KP2 + 1.0 + id * 2.0;
  float sat = 3.;
  float val = 1. - odd;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1.);

  vec3 n = (cmat * wmat * vec4(nrm, 0)).xyz;
  float l = dot(normalize(vec3(.5,1,-3)), n) * .1 + .9;
  //mix(l, 1., pow(s0, .1));

  v_color.rgb *= v_color.a;

  #if 0
  gl_Position.xy /= gl_Position.w;
  gl_Position.z = bv;
  gl_Position.w = 0.1
  #endif
}
// Removed built-in GLSL functions: transpose, inverse