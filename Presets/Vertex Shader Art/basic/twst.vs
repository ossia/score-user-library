/*{
  "DESCRIPTION": "twst",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/jDNMJCu4S7DSRconL)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 6006,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 820,
    "ORIGINAL_LIKES": 8,
    "ORIGINAL_DATE": {
      "$date": 1448650880960
    }
  }
}*/

/*

     _ ._ _|_ _ _ |_ _. _| _ ._ _. ._ _|_
 \/ (/_ | |_ (/_ >< _> | | (_| (_| (/_ | (_| | |_

*/

#define PI radians( 180. )

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p)
{
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

mat4 rotX( float angle ) {
    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      1, 0, 0, 0,
      0, c, s, 0,
      0,-s, c, 0,
      0, 0, 0, 1);
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
  #if 0
  return mat4(
    1, 0, 0, trans[0],
    0, 1, 0, trans[1],
    0, 0, 1, trans[2],
    0, 0, 0, 1);
  #else
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    trans, 1);
  #endif
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1);
}

mat4 uniformScale(float s) {
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
    0, 0, 0, 1);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0, 0,
    0, s[1], 0, 0,
    0, 0, s[2], 0,
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

float m1p1(float v) {
  return v * 2. - 1.;
}

float p1m1(float v) {
  return v * 0.5 + 0.5;
}

float inRange(float v, float minV, float maxV) {
  return step(minV, v) * step(v, maxV);
}

float at(float v, float target) {
  return inRange(v, target - 0.1, target + 0.1);
}

void getShapePoint(const float numPointsPerFace, const float id, const mat4 wvp, out vec4 pos) {
  float numPointsPerShape = pow(numPointsPerFace, 3.);
  float numPointsPerWhat = numPointsPerFace * numPointsPerFace;
  float aId = mod(id, numPointsPerFace);
  float a = aId / numPointsPerFace;
  float bId = mod(floor(id / numPointsPerFace), numPointsPerFace);
  float b = bId / numPointsPerFace;
  float cId = floor(id / numPointsPerWhat);
  float c = cId / numPointsPerFace;
  float a0 = a * PI * 2.;
  float b0 = b * PI * 2.;
  float c0 = c * PI * 2.;

  mat4 m = wvp;
  m *= rotZ(c0);
  m *= rotY(b0);
  m *= rotY(a0);
  pos = m * vec4(1,1,1,1);
}

void main() {
   float animTime = time;

   float orbitAngle = animTime * 0.03456;
   float elevation = sin(animTime * 0.223);
   float fOrbitDistance = 30.;

    vec3 target = vec3(0, 0, 0);
    vec3 eye = vec3(0, 0, 10);
        eye = vec3( sin(orbitAngle) * fOrbitDistance , sin(elevation * 1.11) * 10. , cos(orbitAngle)* fOrbitDistance ) ;
    vec3 up = vec3(0,1,0);

    float numPointsPerFace = 4.;
    float numPointsPerShape = pow(numPointsPerFace, 3.);
    float shapeId = floor(vertexId / numPointsPerShape);
    float shapeCount = floor(vertexCount / numPointsPerShape);
    float shapeV = shapeId / shapeCount;
    float invShapeV = 1. - shapeV;

    float size = floor(pow(shapeCount, 1./3.));
    vec3 p = vec3(
      mod(shapeId, size),
      mod(floor(shapeId / size), size),
      floor(floor(shapeId / size) / size));
    vec3 pv = p / size;
    pv = vec3(0,0,0);

    float snd = 0.;

    vec4 pos;
    mat4 m = ident();
    m *= persp(45., resolution.x / resolution.y, 0.1, 60.);
    m *= cameraLookAt(eye, target, up);
    m *= rotY(sin(time * 0.051 + shapeId * sin(time * 0.13) * 0.07));
    m *= rotZ(sin(time * 0.073 + shapeId * sin(time * 0.21) * 0.06));
    m *= uniformScale(10. * invShapeV);
    getShapePoint(numPointsPerFace, vertexId, m, pos);

    gl_Position = pos;
    gl_PointSize = 4.;
    float z = p1m1(pos.z / pos.w);

   // Final output color
    float hue = time * 0.01 + shapeV * 0.1;
    float sat = 1.;
    float val = 1.;
    v_color = vec4(hsv2rgb(vec3(hue, sat, val)), invShapeV + 0.1);
   v_color = vec4(v_color.rgb * v_color.a, v_color.a);
}
// Removed built-in GLSL functions: transpose, inverse