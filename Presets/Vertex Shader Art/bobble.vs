/*{
  "DESCRIPTION": "bobble",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/3K4LGxEGgP7MLHZnb)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Effects"
  ],
  "POINT_COUNT": 84301,
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
    "ORIGINAL_VIEWS": 1485,
    "ORIGINAL_LIKES": 13,
    "ORIGINAL_DATE": {
      "$date": 1451892603027
    }
  }
}*/

/*

## ## ######## ######## ######## ######## ## ## ###### ## ## ### ######## ######## ######## ### ######## ########
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## ## ###### ######## ## ###### ### ###### ######### ## ## ## ## ###### ######## ## ## ######## ##
 ## ## ## ## ## ## ## ## ## ## ## ## ######### ## ## ## ## ## ######### ## ## ##
  ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
   ### ######## ## ## ## ######## ## ## ###### ## ## ## ## ######## ######## ## ## ## ## ## ## ##

*/

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
  out vec4 vCubeCol)
{
   float fSeed = fCubeId;
   float fPositionBase = fCubeId;
   float fSize = 1.0;

   vec3 vCubeOrigin = vec3( 0.0, 0.0, 0.0 );

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
    float ur = uu; //cos(PI * -0.25) * u + sin(PI * -0.25) * v;
    float vr = v; //sin(PI * -0.25) * v - cos(PI * -0.25) * u;
    float glow = mod(fCubeId, 2.);
    float tm = time * 0.9 + hash(posId * 0.797) * PI * 2.;
    float t = p1m1(sin(tm));
    float st = p1m1(sin(tm + -0.6));
    float tt = 1. - t;
    float fScale = st * mix(1., 1.02, glow);

    vCubeOrigin.x = m1p1(hash(posId)) * 2. * tt;
    vCubeOrigin.y = m1p1(hash(posId * 0.123)) * 2. * tt;
    vCubeOrigin.z = m1p1(hash(posId * 0.347)) * 2. * tt;
    float axisId = floor(fVertexId / 12.);
    vec3 glowOff = vec3(0.97, 0.97, 0.97);

    mat = ident();
    mat *= trans(vCubeOrigin);
    mat *= scale(vec3(
      fScale * mix(1., glowOff.x, glow * at(axisId, 1.)),
      fScale * mix(1., glowOff.y, glow * at(axisId, 2.)),
      fScale * mix(1., glowOff.z, glow * at(axisId, 0.))));

    vCubeCol.xyz = vec3(0,0,0);
}

void main()
{
    float cameraTime = time * 0.1;
    vec3 vCameraPos = vec3(sin(time * 0.137) * 5., sin(time * 0.1) * 3., cos(time * 0.137) * 5.);
    vec3 vCameraTarget = vec3(0);
   vec3 vCameraUp = vec3(0.0, 1, 0);

   float vertexIndex = vertexId;
    float fCubeId = floor( vertexIndex / g_cubeVertexCount );
    float fCubeVertex = mod( vertexIndex, g_cubeVertexCount );

    mat4 mCube;
    vec4 vCubeCol;
    vec3 vCubePos;
    float snd = texture(sound, vec2(hash(fCubeId) * 0.125, 0)).r;

    GetCubePosition( fCubeVertex, fCubeId, mCube, vCubeCol);

    GenerateCubeVertex( fCubeId, fCubeVertex, vCubeCol, vCameraPos, vCubePos );

    mat4 mat = persp(radians(65.), resolution.x / resolution.y, 0.1, 1000.);
    mat *= cameraLookAt(vCameraPos, vCameraTarget, vCameraUp);
    mat *= mCube;

    gl_Position = mat * vec4(vCubePos, 1);

    float glow = mod(fCubeId, 2.);

    vec4 color = vec4(0,1,0,0.9);
    color = vec4(0,0,0,1); //hsv2rgb(vec3(mix(0.6, 0.7, hash(fCubeId)), 1.3, 0.)), 1);
   vec4 vFinalColor = mix(vec4(1. - pow(snd, 25.0),1,1,1), color, glow);

   v_color = vec4(vFinalColor.xyz * vFinalColor.a, vFinalColor.a);
  gl_PointSize = 2.;
}
// Removed built-in GLSL functions: transpose, inverse