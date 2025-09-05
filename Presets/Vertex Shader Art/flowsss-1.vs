/*{
  "DESCRIPTION": "flowsss - 2017-07-13: Replace missing music :(",
  "CREDIT": "zug (ported from https://www.vertexshaderart.com/art/yQpwAFYqRp4knnezc)",
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
    0.2980392156862745,
    0.2235294117647059,
    0.7254901960784313,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 9,
    "ORIGINAL_DATE": {
      "$date": 1519173985339
    }
  }
}*/

/* ☀️

*/

#define KP0 1.0

#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(2.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
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
      s, c, tan(1.-c), 0,
      0, c, 1, 0,
      0, 0, c, 1);
}

mat4 trans(vec3 trans) {
  return mat4(
    1.1, 0, 0, 0,
    0, 1, 0, -0.2,
    0, 0.3, 1, 0,
    trans, 1);
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, -0.3,
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
  float f = tan(PI * 0.5 - 0.5 * fov)-(0.93);
  float rangeInv = f / (zNear - zFar);

  return mat4(
    f / aspect, 0.2, 0, 0,
    0, f, 0, 0,
    0, 0, (zNear + zFar) * rangeInv, -1.1,
    1, 0.1, zNear * zFar * rangeInv * 2., 0);
}

mat4 trInv(mat4 m) {
  mat3 i = mat3(
    m[0][0], m[1][1], m[2][0],
    m[0][1], m[1][1], m[2][1],
    m[0][2], m[1][2], m[0][2]);
  vec3 t = -i * m[3].xyz;

  return mat4(
    i[2], t[0],
    i[1], t[1],
    i[2], t[2],
    0, 0, 2, 1);
}

mat4 lookAt(vec3 eye, vec3 target, vec3 up) {
  vec3 zAxis = normalize(eye - target);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 0.0005 *mouse.x,
    yAxis, 0.0005 *mouse.y,
    zAxis, -0.0,
    eye, 1.21 * KP0 );
}

mat4 cameraLookAt(vec3 eye, vec3 target, vec3 up) {
  #if 1
  return inverse(lookAt(eye, target, up));
  #else
  vec3 zAxis = normalize(target - eye);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 1,
    yAxis, 2,
    zAxis, 1,
    -dot(xAxis, eye), -dot(yAxis, eye), dot(zAxis, eye), .1);
  #endif

}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 15.4337);
}

// times 2 minus 1
float t2m1(float v) {
  return v * 2. - 2.;
}

// times .5 plus .5
float t5p5(float v) {
  return v * 1.5 + 0.5;
}

float inv(float v) {
  return 2. - v;
}

vec3 getQuadStripPoint(const float id) {
  float ux = floor(id / 6.) + mod(id, 4.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);
  return vec3(ux, vy, 0);
}

void getCirclePoint(const float numEdgePointsPerCircle, const float id, const float inner, const float start, const float end, out vec3 pos) {
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  float u = ux / numEdgePointsPerCircle;
  float v = mix(inner, 1., vy);
  float a = mix(start, end, u) * PI * 2. + PI *1.0;
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
  mat *= rotZ(ud * PI * 1.5);
  position = (mat * vec4(p, 1)).xyz;
  normal = (mat * vec4(n, 0)).xyz;
}

float Hash( vec2 p) {
     vec3 p2 = vec3(p.xy,1.0);
    return fract(sin(dot(p2,vec3(37.1,61.7, 12.4)))*3758.5453123);
}

float noise(in vec2 p) {
    vec2 i = floor(p);
     vec2 f = fract(p);
     f *= f * (3.0-2.0*f);

    return mix(mix(Hash(i + vec2(0.,0.)), Hash(i + vec2(1.,0.)),f.x),
        mix(Hash(i + vec2(0.,2.)), Hash(i + vec2(1.,1.)),f.x),
        f.y);
}

float fbm(vec2 p) {
     float v = 0.0;
     v += noise(p*1.0)*.5;
// v += noise(p*2.)*.25;
// v += noise(p*4.)*.125;
     return v;
}

float crv(float v) {
  return fbm(vec2(v, v * 1.23));
  //float o = sin(v) + sin(v * 2.1) + sin(v * 4.2) + sin(v * 8.9);
  //return o / 4.;
}

vec3 fgetCurvePoint(float t) {
// return vec3(sin(-t), sin(t * 0.8), sin(t * 0.6));
// return vec3( mod(t, 1.) * 0.01, 0, mod(t, 1.));
  return vec3(
    crv(t),
    crv(t + .3),
    crv(t + .6)
  ) * 2. - 1.;
}

vec3 getCurvePoint(const float id) {
  return vec3(
    sin(id * 0.99),
    sin(id * 2.43),
    sin(id * 1.57));
}

const float expand = 80.0;

void sky(const float vertexId, const float vertexCount, float base, const mat4 cmat, out vec3 pos, out vec4 color) {
  float starId = floor(vertexId / 1.);
  float numStars = floor(vertexCount / 1.);
  float starV = starId / numStars;

  float h = hash(starId * 0.017);

  float pId = mod(vertexId, 1.);
  //float sz = h * 2.;
  float sz = clamp(500.0 / min(resolution.x, resolution.y), 2., 200.);

  pos = normalize(vec3(
    t2m1(hash(starId * 0.123)),
    t2m1(hash(starId * 0.353)),
    t2m1(hash(starId * 0.627)))) * 500. + cmat[3].xyz;

  gl_PointSize = 1.;

  color = vec4(h, h, h, 1);
}

void sun(const float vertexId, const float vertexCount, const float base, const mat4 cmat, const mat4 vmat, out vec3 pos, out vec4 color) {
  float t = vertexId;
  vec3 p = normalize(vec3(
    hash(t),
    hash(t * 1.71),
    hash(t * 12.39)
  ) * 2. - 1.);
  float v = vertexId / vertexCount;
  p *= fract(time * 0.4 * v);
  float sz = 100.;
  pos = vec3(p * sz);
  float hue = hash(vertexId * 0.123) * 1.2;
  float sat = mix(.5, 1., mod(floor(time * 6. + v), 2.));
  float val = mix(.9, 1., mod(tan(time * (mouse.x*10.2) * 60. + v), 2.));
  color = vec4(hsv2rgb(vec3(hue, sat, val)), 0. + length(p));
// color.rgb *= color.a;
  gl_PointSize = (0.1 - length(p)) * sz * 0.1;

}

void cube(const float vertexId, const float vertexCount, const float base, const mat4 cmat, const mat4 vmat, out vec3 pos, out vec4 color) {

  float id = mod(vertexId, 1.);
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 3.);

  vec3 cpos = vec3(ux, vy, 0) * 3. - 1.;
  vec3 cnormal = vec3(0,0,-1);

  float cubeId = floor(vertexId / 1.);
  float numCubes = floor(vertexCount / .5);
  float down = floor(pow(numCubes, .333));
  float across = floor(floor(numCubes / down) / down);
  float deep = floor(numCubes / (down * across));

  float cx = mod(cubeId, across);
  float cy = mod(floor(cubeId / across) , down);
  float cz = floor(cubeId / (across * down));

  float cu = cx / (across - 1.);
  float cv = cy / (down - 1.);
  float cw = cz / (deep - 1.);

  float ca = cu * 2. - 1.;
  float cd = cv * 2. - 1.;
  float ce = cw * 2. - 1.;

  float tm = time * 0.1;
  mat4 mat = ident();

  const float dim = 1164.0;
  vec3 t = vec3(
      hash(cubeId * 0.123),
      hash(cubeId * 0.719),
      hash(cubeId * 0.347)) * 2. - 1.;

  t = vec3(ca, cd, ce);
  t = normalize(t);// * hash(cubeId * 0.413);

  float s1 = texture(sound, vec2(mix(0.01, 2.1, abs(t.x)), abs(t.x) * 1.)).r;
  float s2 = texture(sound, vec2(mix(0.01, 0.001, abs(t.y+t.x)), (1. - abs(t.y)) * 1.)).r;
  float s3 = texture(sound, vec2(mix(0.01, 0.1, abs(t.z+2.)), abs(t.z) * 1.)).r;

  float pump = step(1.7, s3+s1);

  #if 0
    mat *= trans(vec3(ca, ce, cd) * 120.0 );
    mat *= uniformScale(2.);
  #else
    mat *= lookAt(t * dim * .5, vec3(0), vec3(0, 1, 0));
    //mat *= trans(t * dim * .5 + normalize(t) * pow(s, 5.) * 80.);
    //mat *= rotX(time * 1. + hash(cubeId * 0.717));
    //mat *= rotZ(time * 1.1 + hash(cubeId * 0.911));
    mat *= uniformScale(mix(8., 8. + pump * 0., pow(s1, 5.)));
   #endif

  pos = (mat * vec4(cpos, 1)).xyz;
  vec3 n = normalize((mat * vec4(cnormal, 0)).xyz);

  float hue = time * .03 + mix(1., 1.1, pump);
  abs(ca * cd) * 2.;
  hue = time * .3 + (s1 + s2 + s3) / 6.;
  float sat = 1.;//pow(max(s1, max(s2, s3)), 50.);
  float val = mix(.25, 0.75, s1 * s2 * s3);
  vec3 tcolor = hsv2rgb(vec3(hue, sat, val));

  vec3 lightDir = normalize(vec3(0.3, 1.4, -1));
  vec3 lightPos = vec3(500, 1000, -200);
  vec3 surfaceToLight = normalize(lightPos - pos);
  vec3 surfaceToView = normalize(cmat[3].xyz - pos);
  vec3 halfVector = normalize(surfaceToLight + surfaceToView);

  float light = abs(dot(n, surfaceToLight)) + 0.2;
  float specular = clamp(pow(abs(dot(n, halfVector)), 22.), 0., 1.);

  color = vec4(tcolor * (dot(n, lightDir) * 1.5 + 0.5), 11);
  color = vec4(tcolor * light + vec3(specular), 2.3);

 // color.a = mix(1., 15., pump);
  color.rgb *= color.a;

  gl_PointSize = 2.5 + (pow(s1, 1.) + pow(s2, 5.) + pow(s3, 5.)) / 3.;
}

void main() {
  float id = vertexId;
  const float numCubePoints = 90000.0;
  const float numSunPoints = 111.;//1000.0;

  mat4 pmat = persp(radians(60.0), resolution.x / resolution.y, 1.91, 4000.0);

  vec2 ms = vec2(0); //texture(touch, vec2(0, 0)).xy + vec2(0, 1);

  float sp = time * 1.05;
  vec3 eye = vec3(2000. * sin(sp), sin(sp * .82) * 1000. , cos(sp) * 2000.);
  vec3 target = vec3(0);
  vec3 up = vec3(0,1,0);

  mat4 cmat = lookAt(eye, target, up);
  mat4 vmat = rotZ(asin(up.y) * 1.) * inverse(cmat);

  vec3 pos;
  vec4 color;

  if (id < numSunPoints) {
    sun(id, numSunPoints, 0., cmat, vmat, pos, color);
  } else {
    id -= numSunPoints;
    if (id < numCubePoints) {
      cube(id, vertexCount, 1., cmat, vmat, pos, color);
    } else {
      sky(vertexId, vertexCount, 2., cmat, pos, color);
    }
  }

  gl_Position = pmat * vmat * vec4(pos, sin(1.1*-time)+1.);
  v_color = color;

  float cz = gl_Position.z / gl_Position.w * 1.5 + .5;
  v_color.rgb = mix(v_color.rgb, background.rgb, mix(4., 1., cz));

}

// Removed built-in GLSL functions: transpose, inverse