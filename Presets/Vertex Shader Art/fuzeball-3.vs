/*{
  "DESCRIPTION": "fuzeball",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/xvg4vyvfWjCvKZQfW)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 21600,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.08235294117647059,
    0.1568627450980392,
    0.7803921568627451,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2353,
    "ORIGINAL_LIKES": 13,
    "ORIGINAL_DATE": {
      "$date": 1447867671706
    }
  }
}*/

// _ _ _ _
// __ _____ _ __| |_ _____ _____| |__ __ _ __| | ___ _ __ __ _ _ __| |_
// \ \ / / _ \ '__| __/ _ \ \/ / __| '_ \ / _` |/ _` |/ _ \ '__/ _` | '__| __|
// \ V / __/ | | || __/> <\__ \ | | | (_| | (_| | __/ | | (_| | | | |_
// \_/ \___|_| \__\___/_/\_\___/_| |_|\__,_|\__,_|\___|_| \__,_|_| \__|
//

vec3 gSunColor = vec3(1.0, 1.0, 1.0) * 10.0;

vec3 gSkyTop = vec3( 0.1, 0.2, 0.8 ) * 0.5;
vec3 gSkyBottom = vec3( 0.5, 0.8, 1.0 ) * 1.5;

vec3 gCubeColor = vec3(1.0, 1.0, 1.0);
float gExposure = 1.0;

float gCubeColorRandom = 0.0;

#define MOVE_OUTWARDS

float fAOAmount = 0.8;
float gFloorHeight = -1.0;
float g_cameraFar = 1000.0;

#define PI radians( 180.0 )

// from: http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0., 1.0));
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
   vec3 vColor;
   float fAlpha;
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

void GenerateCubeVertex( const float vertexIndex, const mat4 mat, const vec3 vCubeCol, const vec3 vCameraPos, out SceneVertex outSceneVertex )
{
  vec3 vNormal;

  GetCubeVertex( vertexIndex, mat, outSceneVertex.vWorldPos, vNormal );

  outSceneVertex.vColor = vec3( 0.0 );

  outSceneVertex.fAlpha = 1.0;

  float h = outSceneVertex.vWorldPos.y - gFloorHeight;
  outSceneVertex.vColor += GetSkyLighting( vNormal );
  outSceneVertex.vColor *= mix( 1.0, fAOAmount, clamp( h, 0.0, 1.0 ) );

  outSceneVertex.vColor += GetSunLighting( vNormal );

  outSceneVertex.vColor *= vCubeCol;

  outSceneVertex.vColor += GetSunSpec( outSceneVertex.vWorldPos, vNormal, vCameraPos );
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

void GetCubePosition( float fCubeId, out mat4 mat, out vec3 vCubeCol )
{
   float fSeed = fCubeId;
   float fPositionBase = fCubeId;
   float fSize = 1.0;

   vec3 vCubeOrigin = vec3( 0.0, 0.0, 4.0 );

    float across = 32.;
    float down = 20.;
    float u = mod(fCubeId, across) / across;
    float v = floor(fCubeId / across) / down;
    float lng = u * PI * 2.;
    float lat = v * PI;

    float snd = texture(sound, vec2(mix(0.015, 0.015, u), v * 0.25)).r;

    vCubeOrigin.z += pow(snd, 8.0) * 8.0;
    float fScale = mix(0.1, 0.6, sin(lat)) * mix(0.7, 2.0, pow(snd, 8.0)) * snd;

    mat = ident();
   mat *= rotZ(lng);
   mat *= rotY(lat);
    mat *= trans(vCubeOrigin);
    mat *= uniformScale(fScale);

   vec3 vRandCol;

    float s2 = texture(sound, vec2(mix(0.015, 0.015, u), v * 0.25)).r;

    vCubeCol = mix(hsv2rgb(vec3(time + 0.5, 0., 0.2)) * pow(s2 + 0.25, 90.), vec3(1,1,1), pow(s2, 40.0));
    vCubeCol = mix(vCubeCol, hsv2rgb(vec3(time * 1.,1,1)), step(0.8,s2));
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

    {
      mat4 mCube;
      vec3 vCubeCol;

      GetCubePosition( fCubeId, mCube, vCubeCol );

      GenerateCubeVertex( fCubeVertex, mCube, vCubeCol, vCameraPos, sceneVertex );
    }

    // Fianl output position
 vec3 vViewPos = sceneVertex.vWorldPos;
    vViewPos -= vCameraPos;
   vViewPos = vViewPos * mCamera;

   vec2 vFov = vec2( 1.0, resolution.x / resolution.y ) * fov;
   vec2 vScreenPos = vViewPos.xy * vFov;

 gl_Position = vec4( vScreenPos.xy, -1.0, vViewPos.z );

   // Final output color
   float fExposure = min( gExposure, time * 0.1 );
   vec3 vFinalColor = sqrt( vec3(1.0) - exp2( sceneVertex.vColor * -fExposure ) );

   v_color = vec4(vFinalColor * sceneVertex.fAlpha, 1.);//sceneVertex.fAlpha);
}