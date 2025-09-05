/*{
  "DESCRIPTION": "audio cubes - code from tutorial on vertexshaders.com youtube channel.",
  "CREDIT": "chriscamplin (ported from https://www.vertexshaderart.com/art/gKbNhtAK4AqZvFaQM)",
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
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 67,
    "ORIGINAL_DATE": {
      "$date": 1672748463948
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 4.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

mat4 cameraLookAt(vec3 eye, vec3 target, vec3 up) {
  vec3 zAxis = normalize(target - eye);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 0,
    yAxis, 0,
    zAxis, 0,
    -dot(xAxis, eye), -dot(yAxis, eye), -dot(zAxis, eye), 1);
}

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

vec2 getCirclePoint(float id, float numCircleSegments) {

  float vy = mod(floor(id / 2.0) + floor( id / 3.0), 2.);
  // floor: division; throw away the remainder 000000 111111 222222 333333 444444
  // id: 0 1 2 3 4 5 6 7 8 9 10 11 12
  // 0 0 0 0 0 0 1 1 1 1 1 1 1
  // + 0 1 0 1 0 1 0 1 0 1 0 1 0
  // _____________________________
  // = 0 1 0 1 0 1 0 2 1 2 1 2 1

  float ux = floor(id / 6.0) + mod(id, 2.);
  // id: 0 1 2 3 4 5 6 7 8 9 10 11 12
  // 0 0 1 1 2 2 3 3 4 4 5 5 6
  // + 0 0 0 1 1 1 2 2 2 3 3 3 4
  // _____________________________
  // = 0 1 0 1 0 1 0 2 1 2 1 2 1
  float angle = ux / numCircleSegments * PI * 2.;
  float c = cos(angle);
  float s = sin(angle);
  float radius = vy + 1.0;

  float x = c * radius;
  float y = s * radius;

  return vec2(x, y);
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

void main() {
   //
    float pointId = vertexId;

    vec3 pos;
    vec3 normal;
    getCubePoint(pointId, pos, normal);
    float cubeId = floor(pointId / 36.);
    float numCubes = floor(vertexCount / 36.);
    float cols = floor(sqrt(numCubes));
    float rows = floor(numCubes / cols);

   float sliceId = floor(vertexId / 6.0);
   float oddSlice = mod(sliceId, 2.0); // ) if it's even, one if it's odd
   // vertex ID is number of the vertex
   float x = mod(cubeId, rows); // divide by 10 keep the remainder,
   float y = floor(cubeId / rows); //. floor throws away the remainder 0000 1111 2222

   float s = sin(PI * time + y * 0.25);
   float c = cos(PI * time + x * 0.25);
   float xOff = sin(PI * time * 1.5 + y * 0.25) * 0.01;
   float yOff = cos(time + x * 0.25) * 0.2;
   float zOff = sin(time * x * y * 0.005) * 0.05;

   float u = x /(rows - 1.);
   float v = y / (rows - 1.);\

    float ux = u * 2. - 1. + xOff;
   float vy = v * 2. - 1. - zOff;

   // concentrate on center
   float sv = abs(v - 0.5) * 2.0;
   float su = abs(u - 0.5) * 2.0;

    // circular - atan returns values between PI & -PI
   float au = abs(atan(su, sv)) / PI;
   float av = length(vec2(su, sv));
    // sound

    float snd = texture(sound, vec2(au * 0.05, av * 0.25)).r;
   float aspect = resolution.x / resolution.y;
   float scl = pow(snd + 0.2, 5.); //* mix(1., 1.1, oddSlice); //mix: multiply by 1.0 or 1.1 if it's odd or even
   scl *= 20. / rows;
   //vec2 xy = circleXY * 0.1 * scl + vec2(ux, vy) * 1.25;
   float z = -pow(snd + c, 2.* snd) - zOff + snd;
   //pos -= vec3(circleXY, z);
   mat4 mat = ident();
    float tm = time * 0.1;
    vec3 eye = vec3(cos(tm) * 1., sin(tm * 0.5) * .1 + 1., sin(tm) * 2.* snd);
    vec3 target = vec3(0);
    vec3 up = vec3(0,1,0);
    //mat *= cameraLookAt(eye, target, up);

   mat *= scale(vec3(1, aspect, 1));
    mat *= rotX(radians(45. * mouse.x * mouse.y));
    //mat *= rotY(radians(-45.));
   mat *= rotZ(time * 0.1);
 mat += transpose(mat * snd * mouse.x * mouse.y);
   mat *= trans(vec3(ux, vy, 0) * 1.3);
   mat *= uniformScale(0.02 * scl);
   //mat *= rotY(PI * snd * 0.1 * sign(ux));
   //mat *= rotZ(PI* snd* 0.1 *time * sign(ux));

 gl_Position = mat * vec4(pos, 1.);
    vec3 n = normalize((mat * vec4(normal, 0)).xyz);
    vec3 lightDir = normalize(vec3(0.3, 0.4, -1));

   float pump = step(0.2, 20. * snd);
    float hue = 0.5 - pump * mouse.x * 0.1;
    hue = hue + smoothstep(x, y, snd);
    float sat = 0.8;
   // add more impact using pow
    float val = 1.0; //mix(.1, pow(snd + 0.2, 5.), pump);pow(snd + 0.1, 5.0);
   //val += oddSlice;
    vec3 color = vec3(hsv2rgb(vec3(fract(hue), sat, val)));
    //color *= snd;
    //background += 0.1;
   vec4 newColor = vec4(0.25, 0.02, 0.5, 1.0);
    //vec3 finalColor = mix(vec4(color, 1.), background, s);
 //finalColor = mix(color, newColor, c);
    v_color = vec4(color * (dot(n, lightDir) * 0.5 + 0.5), 1);
  }


// Removed built-in GLSL functions: transpose