/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "sylistine (ported from https://www.vertexshaderart.com/art/yYj8r42nj2y6GRBEi)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 13786,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1600665188097
    }
  }
}*/

#define PI radians(180.)
#define TAU radians(360.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 hsv2rgb(float h, float s, float v) {
  return hsv2rgb(vec3(h, s, v));
}

mat4 rotX( float angle) {
  float s = sin( angle );
  float c = cos( angle );
  return mat4(
    1, 0, 0, 0,
    0, c, -s, 0,
    0, s, c, 0,
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
  float f = tan(PI * 0.5 - fov * 0.5);
  float rangeInv = 1.0 / (zNear - zFar);

  return mat4(
    f / aspect, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (zNear + zFar) * rangeInv, -1,
    0, 0, zNear * zFar * rangeInv * 2., 0);
}

void main() {
  float unitPentagonSideLength = sqrt(pow(cos(TAU/5.)-1., 2.)+pow(sin(TAU/5.), 2.));

  float vertsInIco = 20. * 3.;

  float icoId = floor(vertexId / vertsInIco);
  float icoVertexId = mod(vertexId, vertsInIco);

  float triId = floor(icoVertexId / 3.);
  float triVertexId = mod(vertexId, 3.);
  float halfPi = PI * 0.5;
  float triRads = triVertexId * 0.3333 * PI * 2. + halfPi;
  float bottom = mod(triId, 2.);
  float top = 1. - bottom;
  float pairId = floor(triId / 2.);
  triRads += bottom * PI;
  vec4 pos = vec4(cos(triRads)/sqrt(3.), sin(triRads)/sqrt(3.), -1., 1.);
  pos.y += 0.15 - 0.3 * top;
  //pos *= rotX(PI/12. - PI/6. * (1. - bottom));
  pos *= rotY(PI/5. * triId + time);
  //pos.y += 1./sqrt(3.) - bottom / sqrt(3.);
  float width = 16.;
  pos.x += mod(icoId, width) * 4.;
  pos.y += floor(icoId / width) * 3.;

  /*
  float rowId = floor(pairId / 5.);
  float rowPos = mod(pairId, 5.);
  pos.x += rowPos - rowId * 0.5;
  pos.y -= rowId * sqrt(3.)/2.;
  */

  vec3 cameraPos = vec3(-32., -14., sin(time)-5.);
  mat4 cameraTransform = trans(cameraPos);

  mat4 P = persp(PI/2., resolution.x / resolution.y, 0.1, 100.);
  gl_Position = P * cameraTransform * pos;
  v_color = vec4(hsv2rgb(pos.x/5., 1., 1.), 1.);
  gl_PointSize = 10.;
}