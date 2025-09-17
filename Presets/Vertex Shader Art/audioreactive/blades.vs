/*{
  "DESCRIPTION": "blades",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/aqJ9RgEQBu63bvw2o)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.19607843137254902,
    0.4588235294117647,
    0.4627450980392157,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 537,
    "ORIGINAL_LIKES": 3,
    "ORIGINAL_DATE": {
      "$date": 1608293207123
    }
  }
}*/



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
    yAxis, 0,
    zAxis, 0,
    -dot(xAxis, eye), -dot(yAxis, eye), -dot(zAxis, eye), 1);
  #endif

}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
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

void getCirclePoint(const float numEdgePointsPerCircle, const float id, const float inner, const float start, const float end, out vec3 pos) {
  float outId = id - floor(id / 3.) * 2. - 1.; // 0 1 2 3 4 5 6 7 8 .. 0 1 2, 1 2 3, 2 3 4
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  float u = ux / numEdgePointsPerCircle;
  float v = mix(inner, 1., vy);
  float a = mix(start, end, u) * PI * 2. + PI * 0.0;
  float s = sin(a);
  float c = cos(a);
  float x = c * v;
  float y = s * v;
  float z = 0.;
  pos = vec3(x, y, z);
}

#define CUBE_POINTS_PER_FACE 6.
#define FACES_PER_CUBE 6.
#define POINTS_PER_CUBE (CUBE_POINTS_PER_FACE * FACES_PER_CUBE)
void getCubePoint(const float id, out vec3 position, out vec3 normal) {
  float quadId = floor(mod(id, POINTS_PER_CUBE) / CUBE_POINTS_PER_FACE);
  float sideId = mod(quadId, 3.);
  float flip = mix(1., -1., step(2.5, quadId));
  // 0 1 2 1 2 3
  float facePointId = mod(id, CUBE_POINTS_PER_FACE);
  float pointId = mod(facePointId - floor(facePointId / 3.0), 6.0);
  float a = pointId * PI * 2. / 4. + PI * 0.25;
  vec3 p = vec3(cos(a), 0.707106781, sin(a)) * flip;
  vec3 n = vec3(0, 1, 0) * flip;
  float lr = mod(sideId, 2.);
  float ud = step(2., sideId);
  mat4 mat = rotX(lr * PI * 0.5);
  mat *= rotZ(ud * PI * 0.5);
  position = (mat * vec4(p, 1)).xyz;
  normal = (mat * vec4(n, 0)).xyz;
}

#if 1
void main() {
  float id = vertexId;
  float ux = mod(id, 2.) - 0.5;
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  float bladeId = floor(id / 6.);
  float numBlades = floor(vertexCount / 6.);
  float down = floor(sqrt(numBlades)) * 1.;
  float across = floor(numBlades / down);

  float v = bladeId / numBlades;

  float cx = mod(bladeId, across);
  float cy = floor(bladeId / across);

  float cu = cx / (across - 1.);
  float cv = cy / (down - 1.);

  float ca = cu * 2. - 1.;
  float cd = cv * 2. - 1.;

  vec3 cpos = vec3(ca, 0, cd);
  vec3 pos = vec3(ux, vy, 0);
  vec3 normal = vec3(0, 0, 1);

  float snd = texture(sound, vec2(mix(0.1, 0.25, hash(v * 0.0713)), length(cpos) * .7)).r;

  float tm = time * 0.0125;
  float etm = tm + PI;
  mat4 mat = persp(radians(60.0), resolution.x / resolution.y, 0.1, 1000.0);
  float er = 8.;
  float tr = 8.;
  vec3 eye = vec3(cos(tm) * er, 2.2 /*sin(tm * 0.9) * 1.5*/, sin(tm) * er);
  vec3 target = vec3(cos(etm) * tr, -1., sin(etm) * tr); //vec3(-eye.x, sin(tm * 0.9) * -1.5, -eye.z) * 5.5;
  vec3 up = vec3(0, 1, 0);
  float sh = mix(0.0, 0.1, hash(v * 0.327)) +
    mix(0.0, 0.5, sin(cu * 15.) * 0.5 + 0.5) +
    mix(0.0, 0.5, sin(cv * 15.) * 0.5 + 0.5);
  vec3 h = vec3(
    hash(v) + sin(time * 0.2 + cv * 205. + hash(cv) * 0.1) * vy * 0.2,
    0,
    hash(v * 0.123));
  normal = normalize(vec3(sin(cu * 15.), 1, cos(cv * 15.)));

  mat4 cmat = cameraLookAt(eye, target, up);
  mat *= cmat;
  mat *= trans(cpos * 8. + h);
  mat *= inverse(mat4(
    vec4(cmat[0].xyz, 0),
    vec4(cmat[1].xyz, 0),
    vec4(cmat[2].xyz, 0),
    vec4(0, 0, 0, 1)));
  mat *= rotZ(sin(time + v * 4.) * 0.3);
  mat *= scale(vec3(mix(0.1, 0.01, vy), 1.+ sh + pow(snd + 0.3, 10.0) * 0.1, 1));

  gl_Position = mat * vec4(pos, 1);
  vec3 n = normalize((mat * vec4(normal, 0)).xyz);

  vec3 lightDir = normalize(vec3(0.3, 0.4, -1));

  float hue = time * 0.1 + mix(0.25, 0.35, hash(bladeId * 0.0001 + vertexId * 0.0001));// * 0.25 + 0.1;//sin(time * 3.) * .1, time * 3. + .5, step(0.6, snd));//abs(ca * cd) * 2.;
  float sat = mix(0.5, 0.8, hash(bladeId * 0.0003));//step(0.6, snd);//pow(snd + 0.3, 5.);
  float val = mix(0.7, 1.0, hash(bladeId * 0.0005));
  vec3 color = hsv2rgb(vec3(hue, sat, val));
  float lit = (dot(n, lightDir) * 0.5 + 0.5);
  color = mix(color, vec3(1,1,0), pow(snd + 0.3, 10.0));
  v_color = vec4(color * mix(0., 1., lit), 1.);
  v_color.rgb *= v_color.a;
}
#endif


// Removed built-in GLSL functions: transpose, inverse