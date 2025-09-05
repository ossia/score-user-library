/*{
  "DESCRIPTION": "escnyc - Needs lots of camera work but hey, fake hidden line removal \ud83d\ude01",
  "CREDIT": "zug (ported from https://www.vertexshaderart.com/art/8Tuytbjq9XfyxyLSA)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Effects"
  ],
  "POINT_COUNT": 84379,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1565904585795
    }
  }
}*/



#define parameter0 0.2 //KParameter0 -1.>>1.
#define parameter1 0.2 //KParameter1 -1.>>1.
//KDrawmode=GL_TRIANGLE_STRIP

#define PI radians( 180.0 )

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void GetQuadInfo( const float vertexIndex, out vec2 quadVertId, out float quadId )
{
    float twoTriVertexIndex = mod( vertexIndex, 6.0 );
    float triVertexIndex = mod( vertexIndex, 3.0 );

    if ( twoTriVertexIndex < 0.5 ) quadVertId = vec2( 0.0, 0.0 );
    else if ( twoTriVertexIndex < 1.5 ) quadVertId = vec2( 1.0, 0.0 );
    else if ( twoTriVertexIndex < 2.5 ) quadVertId = vec2( 0.0, 1.0 );
    else if ( twoTriVertexIndex < 3.5 ) quadVertId = vec2( 1.0, 0.0 );
    else if ( twoTriVertexIndex < 4.5 ) quadVertId = vec2( 1.0, 1.0 );
    else quadVertId = vec2( 0.0, 1.0 );

    quadId = floor( vertexIndex / 6.0 );
}

void GetQuadTileInfo( const vec2 quadVertId, const float quadId, const vec2 vDim, out vec2 vQuadTileIndex, out vec2 vQuadUV )
{
    vQuadTileIndex.x = floor( mod( quadId, vDim.x ) );
    vQuadTileIndex.y = floor( quadId / vDim.x );

   vQuadUV.x = floor(quadVertId.x + vQuadTileIndex.x);
    vQuadUV.y = floor(quadVertId.y + vQuadTileIndex.y);

    vQuadUV = vQuadUV * (1.0 / vDim);
}

void GetQuadTileInfo( const float vertexIndex, const vec2 vDim, out vec2 vQuadTileIndex, out vec2 vQuadUV )
{
   vec2 quadVertId;
   float quadId;
 GetQuadInfo( vertexIndex, quadVertId, quadId );
   GetQuadTileInfo( quadVertId, quadId, vDim, vQuadTileIndex, vQuadUV );
}

void GetMatrixFromZY( const vec3 vZ, const vec3 vY, out mat3 m )
{
   vec3 vX = normalize( cross( vY, vZ ) );
   vec3 vOrthoY = normalize( cross( vZ, vX ) );
   m[0] = vX;
   m[1] = vOrthoY;
   m[2] = vZ;
}

void GetMatrixFromZ( vec3 vZAxis, out mat3 m )
{
   vec3 vZ = normalize(vZAxis);
    vec3 vY = vec3( 0.0, 1.0, 0.0 );
   if ( abs(vZ.y) > 0.99 )
    {
       vY = vec3( 1.0, 0.0, 0.0 );
    }
   GetMatrixFromZY( vZ, vY, m );
}

#define g_cubeFaces 6.0
#define g_cubeVerticesPerFace ( 2.0 * 3.0 )
#define g_cubeVertexCount ( g_cubeVerticesPerFace * g_cubeFaces )

// 6 7
// +----------+
// /| /|
// 2 / | 3/ |
// +----------+ |
// | | | |
// Y Z | 4| | 5|
// | +-------|--+
// ^ / | / | /
// |/ 0|/ 1|/
// +--> X +----------+

vec3 GetCubeVertex( float fVertexIndex )
{
 vec3 fResult = vec3( 1.0 );

   float f = fVertexIndex / 8.0;
   if ( fract( f * 4.0 ) < 0.5 )
    {
     fResult.x = -fResult.x;
    }

   if ( fract( f * 2.0 ) < 0.5 )
    {
     fResult.y = -fResult.y;
    }

   if ( fract( f ) < 0.5 )
    {
     fResult.z = -fResult.z;
    }

   return fResult;
}

void GetCubeVertex( const float vertexIndex, out vec3 vWorldPos )
{
   float fFaceIndex = floor( vertexIndex / g_cubeFaces );

   vec3 v0, v1, v2, v3;

   if ( fFaceIndex < 0.5 )
    {
       v0 = GetCubeVertex( 0.0 );
       v1 = GetCubeVertex( 2.0 );
       v2 = GetCubeVertex( 3.0 );
       v3 = GetCubeVertex( 1.0 );
    }
   else if ( fFaceIndex < 1.5 )
    {
       v0 = GetCubeVertex( 5.0 );
       v1 = GetCubeVertex( 7.0 );
       v2 = GetCubeVertex( 6.0 );
       v3 = GetCubeVertex( 4.0 );
    }
   else if ( fFaceIndex < 2.5 )
    {
       v0 = GetCubeVertex( 1.0 );
       v1 = GetCubeVertex( 3.0 );
       v2 = GetCubeVertex( 7.0 );
       v3 = GetCubeVertex( 5.0 );
    }
   else if ( fFaceIndex < 3.5 )
    {
       v0 = GetCubeVertex( 4.0 );
       v1 = GetCubeVertex( 6.0 );
       v2 = GetCubeVertex( 2.0 );
       v3 = GetCubeVertex( 0.0 );
    }
   else if ( fFaceIndex < 4.5 )
    {
       v0 = GetCubeVertex( 2.0 );
       v1 = GetCubeVertex( 6.0 );
       v2 = GetCubeVertex( 7.0 );
       v3 = GetCubeVertex( 3.0 );
    }
   else
    {
       v0 = GetCubeVertex( 1.0 );
       v1 = GetCubeVertex( 5.0 );
       v2 = GetCubeVertex( 4.0 );
       v3 = GetCubeVertex( 0.0 );
    }
   float fFaceVertexIndex = mod( vertexIndex, 6.0 );

   if ( fFaceVertexIndex < 0.5 )
    {
    vWorldPos = v0;
    }
   else if ( fFaceVertexIndex < 1.5 )
    {
    vWorldPos = v1;
    }
   else if ( fFaceVertexIndex < 2.5 )
    {
    vWorldPos = v2;
    }
   else if ( fFaceVertexIndex < 3.5 )
    {
    vWorldPos = v0;
    }
   else if ( fFaceVertexIndex < 4.5 )
    {
    vWorldPos = v2;
    }
   else
    {
    vWorldPos = v3;
    }
}

void GenerateCubeVertex(
  const float fCubeId,
  const float vertexIndex,
  const vec4 vCubeCol,
  const vec3 vCameraPos,
  out vec3 outSceneVertex )
{
  GetCubeVertex( vertexIndex, outSceneVertex);
}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p)
{
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

mat4 rotX(float angle) {

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
    xAxis, 0.,
    yAxis, 0.,
    zAxis, 0.,
    -dot(xAxis, eye), -dot(yAxis, eye), -dot(zAxis, eye), 1);
  #endif

}

float m1p1(float v) {
  return v * 2. - 1.;
}

float p1m1(float v) {
  return v * .5 + .5;
}

float inRange(float v, float minV, float maxV) {
  return step(minV, v) * step(v, maxV);
}

float at(float v, float target) {
  return inRange(v, target - 0.1, target + 0.1);
}

void GetCubePosition(
  float fVertexId,
  float fCubeId,
  out mat4 mat,
  out vec4 vCubeCol,
  out float snd)
{
   float fSeed = fCubeId;
   float fPositionBase = fCubeId;
   float fSize = 1.50;

   vec3 vCubeOrigin = vec3( -1.0, 0.0, 0.0);

    float posId = floor(fCubeId / 2.);
    float across = 32.;
    float down = 40.;
    float u2 = mod(posId, across);
    float v2 = floor(posId / across);
    float u = u2 / across;
    float v = v2 / down;
    float lng = u * PI * 2.;
    float lat = v * PI;

    float uBlock = floor(u2 / 4.);
    float vBlock = floor(v2 / 4.);

    float uu = abs(m1p1(u));
    float ur = uu; cos(PI * -0.25) * u + sin(PI * -0.25) * v;
    float vr = v; sin(PI * 0.25) * v - cos(PI * -0.25) * u;
    snd = texture(sound, vec2(mix(0.05, 0.25, ur), vr * 0.5)).r;
    float glow = mod(fCubeId, 2.);
    float glowScale = glow * 2.;
    //vCubeOrigin.z += pow(snd, 10.0) * 10.0;
    float fScale = 1. + glowScale * 0.01;
    float height = mix(1.0, 8.0, pow(hash(posId), 3.0));

    vCubeOrigin.x = m1p1(u) * across * 1.2 + uBlock * 3.;
    vCubeOrigin.y = height;
    vCubeOrigin.z = m1p1(v) * down * 1.2 + vBlock * 3.;

    float axisId = floor(fVertexId / 12.);
    vec3 glowOff = vec3(0.999, 0.92, 0.98);

    mat = ident();
 // mat *= rotZ(lng);
 // mat *= rotY(lat);
    mat *= trans(vCubeOrigin);
    mat *= scale(vec3(
      fScale * mix(1., glowOff.x, glow * at(axisId, 1.)),
      height * fScale + mix(1., glowOff.y, glow * at(axisId, 2.)),
      fScale * mix(1., glowOff.z, glow * at(axisId, 0.))));

   vec3 vRandCol;

    float s2 = texture(sound, vec2(mix(0.015, 0.015, u), v * 0.1)).r;

    vCubeCol.xyz = mix(vec3(0.0), vec3(1,1,1), pow(s2, 40.0));
    vCubeCol.xyz = mix(vCubeCol.xyz, vec3(1,0,0), step(0.95,s2));
    vCubeCol.xyz = vec3(0,0,0);

}

vec3 getCameraPointLow(float t) {
  t = mod(t, 4.);
  if (t < 1.) return vec3( -28, 9,-26); // red
  if (t < 2.) return vec3( -28, 9, 25); // yellow
  if (t < 3.) return vec3( 22, 9, 25); // lime
  if (t < 4.) return vec3( 33, 9,-26); // aqua-green
  return vec3(0.0);
}

vec3 getCameraPoint(float t) {
  vec3 p0 = getCameraPointLow(t);
  vec3 p1 = getCameraPointLow(t + 1.);
  return mix(p0, p1, fract(t));
}

/*
const float tension = 1.;
vec3 getCameraPos(float t) {
  vec3 p0 = getCameraPointLow(t);
  vec3 p1 = getCameraPointLow(t + 1.);
  vec3 p2 = getCameraPointLow(t + 2.);
  vec3 p3 = getCameraPointLow(t + 3.);

  float subV = fract(t);
  float s2 = pow(subV, 2.);
  float s3 = pow(subV, 3.);

  float c1 = 2. * s3 - 3. * s2 + 1.;
  float c2 = -(2. * s3) + 3. * s2;
  float c3 = s3 - 2. * s2 + subV;
  float c4 = s3 - s2;

  vec3 t1 = (p2 - p0) * tension;
  vec3 t2 = (p3 - p1) * tension;
  return c1 * p1 + c2 * p2 + c3 * t1 + c4 * t2;
}

*/
vec3 getCameraPos(float t) {
  return getCameraPoint(t);
}

void main()
{
   vec2 vMouse = mouse;

   float fov = 1.5;

   float animTime = time * 0.01+(parameter0);

    float cameraTime = time * 0.5*parameter1;
    vec3 vCameraPos = getCameraPos(cameraTime);
    vCameraPos.y = mix(2., 22., p1m1(sin(cameraTime * 3.73)));

    vec3 vCameraTarget = getCameraPos(cameraTime + 0.2);
    vec3 vT2 = getCameraPos(cameraTime + 0.4);
    vCameraTarget.y = mix(2., 22., p1m1(sin(cameraTime * 3.73 + 0.2)));
   vec3 vCameraUp = vec3( 0.0, 1, 0);
    float slide = 1. - p1m1(dot(
      normalize(vCameraTarget.xz - vCameraPos.xz),
      normalize(vT2.xz - vCameraTarget.xz)));

    mat4 matC = trans(vCameraPos);
    matC *= rotY(atan(
      vCameraPos.x - vCameraTarget.x,
      vCameraPos.z - vCameraTarget.z));
    matC *= rotZ(-0.6 * slide);
    matC *= rotX((vCameraPos.y - vCameraTarget.y) * -0.2);

   float vertexIndex = vertexId;
    float fCubeId = floor( vertexIndex / g_cubeVertexCount );
    float fCubeVertex = mod( vertexIndex, g_cubeVertexCount );

    mat4 mCube;
    vec4 vCubeCol;
    vec3 vCubePos;
    float snd;

    GetCubePosition( fCubeVertex, fCubeId, mCube, vCubeCol, snd );

    GenerateCubeVertex( fCubeId, fCubeVertex, vCubeCol, vCameraPos, vCubePos );

    mat4 mat = persp(radians(65.), resolution.x / resolution.y, 0.1, 1000.);
    mat *= inverse(matC);
  cameraLookAt(vCameraPos, vCameraTarget, vCameraUp);
    mat *= mCube;

    gl_Position = mat * vec4(vCubePos, 1);

    float glow = mod(fCubeId, 2.);

    vec4 color = vec4(0,1,0,0.9);
    color = vec4(hsv2rgb(vec3(floor(mod(cameraTime, 4.)) / 8., 1, 1)), 1);
   vec4 vFinalColor = mix(vec4(0,0,0,1), color, glow);

   v_color = vec4(vFinalColor.xyz * vFinalColor.a, vFinalColor.a);
}
// Removed built-in GLSL functions: transpose, inverse