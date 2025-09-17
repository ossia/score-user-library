/*{
  "DESCRIPTION": "jjblox",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/RJ4Tjj3PSsq4kvDcc)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Effects"
  ],
  "POINT_COUNT": 87554,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 388,
    "ORIGINAL_DATE": {
      "$date": 1448522234366
    }
  }
}*/

/*

        __ __ __ __
 _ _____ _____/ /____ _ _______/ /_ ____ _____/ /__ _________ ______/ /_
| | / / _ \/ ___/ __/ _ \| |/_/ ___/ __ \/ __ `/ __ / _ \/ ___/ __ `/ ___/ __/
| |/ / __/ / / /_/ __/> <(__ ) / / / /_/ / /_/ / __/ / / /_/ / / / /_
|___/\___/_/ \__/\___/_/|_/____/_/ /_/\__,_/\__,_/\___/_/ \__,_/_/ \__/

*/

vec3 gSunColor = vec3(1.0, 1.0, 1.0) * 10.0;

vec3 gSkyTop = vec3( 0.1, 0.2, 0.8 ) * 0.5;
vec3 gSkyBottom = vec3( 0.5, 0.8, 1.0 ) * 1.5;

vec3 gCubeColor = vec3(1.0, 1.0, 1.0);
float gExposure = 1.0;

float gCubeColorRandom = 0.0;

#define MOVE_OUTWARDS

float fAOAmount = 10.83;
float gFloorHeight = -1.0;
float g_cameraFar = 1000.0;

#define PI radians( 180.0 )

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 GetSunDir()
{
   return normalize( vec3( 1.0, 0.3, -0.5 ) );
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

struct SceneVertex
{
   vec3 vWorldPos;
   vec4 vColor;
};

float GetCosSunRadius()
{
  return 0.01;
}

float GetSunIntensity()
{
   return 0.001;
}

vec3 GetSkyColor( vec3 vViewDir )
{
 return mix( gSkyBottom, gSkyTop, max( 0.0, vViewDir.y ) );
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

void GetCubeVertex( const float vertexIndex, const mat4 mat, out vec3 vWorldPos, out vec3 vWorldNormal )
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
  #if 0
   v0 = (vec4(v0, 1) * mat).xyz;
   v1 = (vec4(v1, 1) * mat).xyz;
   v2 = (vec4(v2, 1) * mat).xyz;
   v3 = (vec4(v3, 1) * mat).xyz;
  #else
   v0 = (mat * vec4(v0, 1)).xyz;
   v1 = (mat * vec4(v1, 1)).xyz;
   v2 = (mat * vec4(v2, 1)).xyz;
   v3 = (mat * vec4(v3, 1)).xyz;
  #endif
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

   vWorldNormal = normalize( cross( v1 - v0, v2 - v0 ) );
}

vec3 GetSunLighting( const vec3 vNormal )
{
   vec3 vLight = -GetSunDir();

   float NdotL = max( 0.0, dot( vNormal, -vLight ) );

   return gSunColor * NdotL;
}

vec3 GetSunSpec( const vec3 vPos, const vec3 vNormal, const vec3 vCameraPos )
{
   vec3 vLight = -GetSunDir();

   vec3 vView = normalize( vCameraPos - vPos );

   vec3 vH = normalize( vView - vLight );

   float NdotH = max( 0.0, dot( vNormal, vH ) );
   float NdotL = max( 0.0, dot( vNormal, -vLight ) );

   float f = mix( 0.01, 1.0, pow( 1.0 - NdotL, 5.0 ) );

   return gSunColor * pow( NdotH, 20.0 ) * NdotL * f * 4.0;
}

vec3 GetSkyLighting( const vec3 vNormal )
{
   vec3 vSkyLight = normalize( vec3( -1.0, -2.0, -0.5 ) );

   float fSkyBlend = vNormal.y * 0.5 + 0.5;

   return mix( gSkyBottom, gSkyTop, fSkyBlend );
}

void GenerateCubeVertex( const float fCubeId, const float vertexIndex, const mat4 mat, const vec4 vCubeCol, const vec3 vCameraPos, out SceneVertex outSceneVertex )
{
  vec3 vNormal;
  float glow = mod(fCubeId, 2.);

  GetCubeVertex( vertexIndex, mat, outSceneVertex.vWorldPos, vNormal );

  outSceneVertex.vColor = vec4(0,0,0,1);

  float h = outSceneVertex.vWorldPos.y - gFloorHeight;
  outSceneVertex.vColor.xyz += GetSkyLighting( vNormal );
  outSceneVertex.vColor.xyz *= mix( 1.0, fAOAmount, clamp( h, 0.0, 1.0 ) );

  outSceneVertex.vColor.xyz += GetSunLighting( vNormal );

  outSceneVertex.vColor.xyz *= vCubeCol.rgb;

  outSceneVertex.vColor.xyz += GetSunSpec( outSceneVertex.vWorldPos, vNormal, vCameraPos );
}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p)
{
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
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

float m1p1(float v) {
  return v * 2. - 1.;
}

float inRange(float v, float minV, float maxV) {
  return step(minV, v) * step(v, maxV);
}

float at(float v, float target) {
  return inRange(v, target - 0.1, target + 0.1);
}

void GetCubePosition( float fVertexId, float fCubeId, out mat4 mat, out vec4 vCubeCol, out float snd)
{
   float fSeed = fCubeId;
   float fPositionBase = fCubeId;
   float fSize = 1.0;

   vec3 vCubeOrigin = vec3( 0.0, 0.0, 0.0 );

    float posId = floor(fCubeId / 4.);
    float side = m1p1(mod(floor(fCubeId / 2.), 2.));
    float across = 32.;
    float down = 20.;
    float u = mod(posId, across) / across;
    float v = floor(posId / across) / down;
    float lng = u * PI * 2.;
    float lat = v * PI;

    float uu = abs(m1p1(u));
    float ur = uu; //cos(PI * -0.25) * u + sin(PI * -0.25) * v;
    float vr = v; //sin(PI * -0.25) * v - cos(PI * -0.25) * u;
    snd = texture(sound, vec2(mix(0.05, 0.25, ur), vr * 0.05)).r;
    float glow = mod(fCubeId, 2.);
    float glowScale = pow(snd, 5.) * glow * 6.;
    //vCubeOrigin.z += pow(snd, 10.0) * 10.0;
    float fScale = 0.1 + glowScale * 0.2;//mix(0.1, 0.6, sin(lat)) * snd * 1.02;
    vCubeOrigin.x = side * 6. * (1. - pow(snd, 5.) * 2.);
    vCubeOrigin.y = m1p1(v) * 10.;
    vCubeOrigin.z = m1p1(u) * 10.;

    float axisId = floor(fVertexId / 12.);

    mat = ident();
 // mat *= rotZ(lng);
 // mat *= rotY(lat);
    mat *= trans(vCubeOrigin);
    mat *= scale(vec3(
      fScale * mix(1., 0.33, glow * at(axisId, 1.)),
      fScale * mix(1., 0.33, glow * at(axisId, 2.)),
      fScale * mix(1., 0.33, glow * at(axisId, 0.))));

   vec3 vRandCol;

    float s2 = texture(sound, vec2(mix(0.015, 0.015, u), v * 0.1)).r;

    vCubeCol.xyz = mix(vec3(0.0), vec3(1,1,1), pow(s2, 40.0));
    vCubeCol.xyz = mix(vCubeCol.xyz, vec3(1,0,0), step(0.95,s2));
    vCubeCol.xyz = vec3(0,0,1);

  #if 0
    vCubeCol.xyz = hsv2rgb(vec3(axisId / 3., 1, 1));
    vCubeCol.xyz =
      at(axisId, 0.) * vec3(1,1,0) * 1. +
      at(axisId, 1.) * vec3(1,0,1) * 1. +
      at(axisId, 2.) * vec3(0,1,1) * 1. ;
  #endif
}

void main()
{
   SceneVertex sceneVertex;

   vec2 vMouse = mouse;

   float fov = 1.5;

   float animTime = time;

   float orbitAngle = animTime * 0.3456 + 4.0;
   float elevation = -2.2 + (sin(animTime * 0.223 - PI * 0.5) * 0.5 + 0.5) * 0.5;
   float fOrbitDistance = 25.0 + (cos(animTime * 0.2345) * 0.5 + 0.5 ) * 10.0;

   vec3 vCameraTarget = vec3( 0.0, 1.0, 0.0 );
   vec3 vCameraPos = vCameraTarget + vec3( sin(orbitAngle) * cos(elevation), sin(elevation * 1.11), cos(orbitAngle * 0.97) * cos(elevation) ) * fOrbitDistance;
   vec3 vCameraUp = vec3( 0.1, 1.0, 0.0 );

   vec3 vCameraForwards = normalize(vCameraTarget - vCameraPos);

   mat3 mCamera;
    GetMatrixFromZY( vCameraForwards, normalize(vCameraUp), mCamera );

   float vertexIndex = vertexId;

    float fCubeId = floor( vertexIndex / g_cubeVertexCount );
    float fCubeVertex = mod( vertexIndex, g_cubeVertexCount );

      mat4 mCube;
      vec4 vCubeCol;
      float snd;

      GetCubePosition( fCubeVertex, fCubeId, mCube, vCubeCol, snd );

      GenerateCubeVertex( fCubeId, fCubeVertex, mCube, vCubeCol, vCameraPos, sceneVertex );

    // Fianl output position
 vec3 vViewPos = sceneVertex.vWorldPos;
    vViewPos -= vCameraPos;
   vViewPos = vViewPos * mCamera;

   vec2 vFov = vec2( 1.0, resolution.x / resolution.y ) * fov;
   vec2 vScreenPos = vViewPos.xy * vFov;

 gl_Position = vec4( vScreenPos.xy, -1.0, vViewPos.z );

    float glow = mod(fCubeId, 2.);

   // Final output color
   float fExposure = min( gExposure, time * 0.1 );
   vec4 vFinalColor = vec4(sqrt( vec3(1.0) - exp2( sceneVertex.vColor.xyz * -fExposure ) ), sceneVertex.vColor.a);
    vFinalColor = mix(vFinalColor, vec4(1,1,1,0.9), glow);

   v_color = vec4(vFinalColor.xyz * vFinalColor.a, vFinalColor.a);
}