/*{
  "DESCRIPTION": "Spiral",
  "CREDIT": "orange4glace (ported from https://www.vertexshaderart.com/art/Mn5Lhm33cELxeTJsN)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 800,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.0784313725490196,
    0.0784313725490196,
    0.0784313725490196,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 13,
    "ORIGINAL_DATE": {
      "$date": 1643991446311
    }
  }
}*/

#define EXP 2.718
#define PI 3.1415926535897932

mat4 persp(float fov, float aspect, float zNear, float zFar) {
  float f = tan(PI * 0.5 - 0.5 * fov);
  float rangeInv = 1.0 / (zNear - zFar);

  return mat4(
    f / aspect, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (zNear + zFar) * rangeInv, -1,
    0, 0, zNear * zFar * rangeInv * 2., 0);
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

float spiral(float x) {
  return pow(EXP, -0.1 * x);
}

void main() {
  float t = (PI * 8.) * (vertexId / vertexCount);
  float x = 0.5 * pow(EXP, 0.15 * t) * cos(2. * t);
  float y = 0.5 * pow(EXP, 0.15 * t) * sin(2. * t);
  float z = 0.5 * pow(EXP, 0.15 * t);
  vec3 pos = vec3(x, y, z) / (PI * 8.);

  float tm = time * .5;
  float rd = 3.;
  mat4 mat = persp(PI * 0.25, resolution.x / resolution.y, 0.1, 100.);
  vec3 eye = vec3(
    cos(tm) * rd,
    cos(tm) * rd,
    sin(tm) * rd
  );
  vec3 target = vec3(0);
  vec3 up = vec3(0,1,0);

  mat *= cameraLookAt(eye, target, up);

  gl_Position = mat * vec4(pos, 1.0);
  gl_PointSize = 2.;

  float c = vertexId / vertexCount;
  v_color = vec4(c, c, c, 1);
}
// Removed built-in GLSL functions: inverse