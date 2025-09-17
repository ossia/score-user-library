/*{
  "DESCRIPTION": "geodesic2",
  "CREDIT": "tdhooper (ported from https://www.vertexshaderart.com/art/McGjF3J5vvtWpxnDw)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 12093,
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
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_DATE": {
      "$date": 1493928894128
    }
  }
}*/

// --------------------------------------------------------
// Spectrum colour palette
// IQ https://www.shadertoy.com/view/ll2GD3
// --------------------------------------------------------

vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) {
    return a + b*cos( 6.28318*(c*t+d) );
}

vec3 spectrum(float n) {
    return pal( n, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.33,0.67) );
}

// --------------------------------------------------------
// Camera and display
// gman https://www.vertexshaderart.com/art/7TrYkuK4aHzLqvZ7r
// --------------------------------------------------------

#define PI radians(180.0)

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

struct Tri {
    vec3 a;
    vec3 b;
    vec3 c;
};

vec3 bToC(Tri tri, float a, float b, float c) {
    return a * tri.a + b * tri.b + c * tri.c;
}

vec3 bToC(Tri tri, vec3 bary) {
    return bary.x * tri.a + bary.y * tri.b + bary.z * tri.c;
}

float calcTriRow(float n) {
  return floor( (1. + sqrt(1. + 8. * n)) / 2. ) - 1.;
}

vec3 triVertex(Tri tri, float row, float column, float rows, float index, float doSecondPass) {
  float doFirstPass = 1. - doSecondPass;

  // First pass offsets
  row += min(index, 1.) * doFirstPass;
  column += max(index - 1., 0.) * doFirstPass;

  // Second pass offsets
  row += max(index, 1.) * doSecondPass;
  column += min(index, 1.) * doSecondPass;

  // Cartesian coordinates for column/row
  float mixA = row / rows;
  float mixB = column / max(row, 1.);
  vec3 vertex = mix(tri.a, mix(tri.b, tri.c, mixB), mixA);
  return vertex;
}

vec3 pick(vec3 a, vec3 b, vec3 c, float index) {
 return mix(mix(a, b, index), c, max(index - 1., 0.));
}

struct GeoPoints {
 vec3 vertex;
   vec3 center;
};

// Find vertex and center in triangle with n subdivision rows at index
GeoPoints geoPoints(Tri tri, float rows, float i) {
  float firstPass = (rows - 1.) * (rows + 2.) / 2. + 1.;

  // Sub-tringle vertex index
  float id = mod(i, 3.);

  //firstPass = 56.;

  // Repeat whole triangle
  ///i = mod(i, rows * rows* 3.);

  // Sub-triangle index
  i = floor(i / 3.);

  // First pass is upwards pointing triangles,
  // second pass fills in the gaps
  float doSecondPass = max(0., sign(i - firstPass + 1.));

  i -= firstPass * doSecondPass;

  float row = calcTriRow(i);
  float startOfRow = row * (row + 1.) / 2.;
  float column = mod(i - startOfRow, row + 1.);

  vec3 vertexA = triVertex(tri, row, column, rows, 0., doSecondPass);
  vec3 vertexB = triVertex(tri, row, column, rows, 1., doSecondPass);
  vec3 vertexC = triVertex(tri, row, column, rows, 2., doSecondPass);

  vec3 vertex = pick(vertexA, vertexB, vertexC, id);
  vec3 center = (vertexA + vertexB + vertexC) / 3.;

  return GeoPoints(vertex, center);
}

#define PHI (1.618033988749895)
     // PHI (sqrt(5)*0.5 + 0.5)

#define IcoVert0 normalize(vec3(0, PHI, 1))
#define IcoVert1 normalize(vec3(0, PHI, -1))
#define IcoVert2 normalize(vec3(0, -PHI, 1))
#define IcoVert3 normalize(vec3(0, -PHI, -1))
#define IcoVert4 normalize(vec3(1, 0, PHI))
#define IcoVert5 normalize(vec3(1, 0, -PHI))
#define IcoVert6 normalize(vec3(-1, 0, PHI))
#define IcoVert7 normalize(vec3(-1, 0, -PHI))
#define IcoVert8 normalize(vec3(PHI, 1, 0))
#define IcoVert9 normalize(vec3(PHI, -1, 0))
#define IcoVert10 normalize(vec3(-PHI, 1, 0))
#define IcoVert11 normalize(vec3(-PHI, -1, 0))

float beat(float i, float loop) {
 return 1. - min(mod(i, loop), 1.);
}

float signbeat(float i, float loop) {
 return beat(i, loop) * 2. - 1.;
}

vec3 shift(vec3 v, float offset) {
 offset = mod(offset, 3.);
   if (offset == 0.) {
      return v.xyz;
   }
  if (offset == 1.) {
      return v.zxy;
   }
  if (offset == 2.) {
      return v.yzx;
   }
}


// Step through each vertex of each icosahedron face
vec3 icosahedronFaceVertex(float i) {

  float stage, stageIndexOffset, stageLength;
  float a, a0, a1, a2, b, b0, b1, b2, offset, offset0, offset1,offset2;

  stage = round( log2( floor(i / 6.) + 2.) - 1.);
  stageIndexOffset = 6. * (stage * stage);
  i -= stageIndexOffset;
  stageLength = 3. * (stage + 1.) * (stage + 2.);

  float floatFudge = .01; // Fixes rounding issue on OS X
  float invert = floor(i / stageLength * (2. + floatFudge)) * 2. - 1.;

  // Stage 0
  a0 = invert;
  b0 = invert;
  offset0 = mod(i, 3.);

  // Stage 1
  a1 = invert;
  b1 = signbeat(i, 3.) * -1. * invert;
  offset1 = mod(floor(i / 3.) - beat(i - 2., 3.), 3.);

  // Stage 2
  a2 = b1;
  b2 = signbeat(i - 2., 3.) * -1. * invert;
  offset2 = mod(floor(i / 6.) + (1. - beat(i, 3.)) + beat(i - 5., 6.), 3.);

  // Pick stage to show
  float blend1 = stage;
  float blend2 = max(0., stage - 1.);
  a = mix(mix(a0, a1, blend1), a2, blend2);
  b = mix(mix(b0, b1, blend1), b2, blend2);
  offset = mix(mix(offset0, offset1, blend1), offset2, blend2);

  vec3 icoVert = normalize(vec3(PHI, 1, 0));
  icoVert *= vec3(a, b, 1.);
  icoVert = shift(icoVert, offset);
  //icoVert = normalize(icoVert);
  return icoVert;
}

float mb(GeoPoints geo, vec3 origin, float index) {
   vec3 o2 = vec3(1,0,0);
   //origin = vec3(0,1,0);
   vec3 pos = mix(geo.center, geo.vertex, sin(time) * .5 + .5);

   float blendVertex = abs(dot(geo.vertex, origin));
 float blendCenter = abs(dot(geo.center, origin));

   float b1 = sin(blendVertex * 20. + time) * .5 + .5;
   float b2 = sin(blendCenter * 10. + time*-2.) * .5 + .5;

   return b1 + b2 * (sin(time * .5) * .5 + .5) * 1.2;

   float x = abs(dot(pos, vec3(0,1,0)));
   float y = abs(dot(pos, vec3(1,0,0)));
   vec4 a = texture(sound, vec2(x, 240. * y));
 return a.a;
 //return blend;
 //return sin(blend * 20. + time * -5.) * .5 + .5;
}

void main() {
  float numQuads = floor(vertexCount / 6.);
  float around = 100.;
  float down = numQuads / around;
  float quadId = floor(vertexId / 6.);

  float qx = mod(quadId, around);
  float qy = floor(quadId / around);

  // 0--1 3
  // | / /|
  // |/ / |
  // 2 4--5
  //
  // 0 1 0 1 0 1
  // 0 0 1 0 1 1

  float edgeId = mod(vertexId, 6.);
  float ux = mod(edgeId, 2.);
  float vy = mod(floor(edgeId / 2.) + floor(edgeId / 3.), 2.);

  float qu = (qx + ux) / around;
  float qv = (qy + vy) / down;

  float r = sin(qv * PI);
  float x = cos(qu * PI * 2.) * r;
  float z = sin(qu * PI * 2.) * r;

  vec3 pos = vec3(x, cos(qv * PI), z);
  float maxPoints = vertexCount;

  float subdivisionRows = floor(sqrt(vertexCount / 20. / 3.));
  //subdivisionRows = 2.;
  float trianglesPerFace = subdivisionRows * subdivisionRows;
  maxPoints = trianglesPerFace * 3. * 20.;
  float i = min(vertexId, maxPoints);
  float faceIndex = floor(i / (trianglesPerFace * 3.));

  //faceIndex = 0.;

  Tri tri = Tri(
   icosahedronFaceVertex(faceIndex * 3. + 0.),
    icosahedronFaceVertex(faceIndex * 3. + 1.),
    icosahedronFaceVertex(faceIndex * 3. + 2.)
  );

  i = mod(i, trianglesPerFace * 3.);
  GeoPoints geo = geoPoints(tri, subdivisionRows, i);
  pos = geo.vertex;
  pos = normalize(pos);

  //pos = icosahedronFaceVertex(vertexId);

  float blend2 = 0.;
  blend2 += mb(geo, IcoVert0, 0.);
  blend2 += mb(geo, IcoVert1, 1.);
  blend2 += mb(geo, IcoVert4, 2.);
  blend2 += mb(geo, IcoVert5, 3.);
  blend2 += mb(geo, IcoVert8, 4.);
  blend2 += mb(geo, IcoVert9, 5.);

  blend2 /= 5.;

  float blend = blend2;
  //blend = pow(blend, (sin(time * 5.) * .5 + .5) * 10.);
  //blend = blend2 * 5. - 10.;

  pos *= mix(.5, .8, blend);

  float tm = time * .5;
  tm = 8.;
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

  vec4 pos4 = mat * vec4(pos, 1);
  //pos4 = vec4(pos, 1.);

  gl_Position = pos4;
  gl_PointSize = 4.;

  vec3 col = vec3(spectrum(vertexId / maxPoints));
  //col = vec3(.5);
  col *= smoothstep(rd*3., rd, pos4.z);
  col += pow((dot(normalize(pos4.xyz), vec3(.5,-.5,0))) * 2., 2.);

  col = spectrum(blend);

  v_color = vec4(col, 1.);

}
// Removed built-in GLSL functions: transpose, inverse
