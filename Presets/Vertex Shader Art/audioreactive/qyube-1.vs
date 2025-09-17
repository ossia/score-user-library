/*{
  "DESCRIPTION": "qyube",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/mHgyhLsuwpJinyxDH)",
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
    0.21176470588235294,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 85,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1665266372962
    }
  }
}*/

/*

 ___ ___ _______ ________ _________ _______ ___ ___
|\ \ / /|\ ___ \ |\ __ \|\___ ___|\ ___ \ |\ \ / /|
\ \ \ / / \ \ __/|\ \ \|\ \|___ \ \_\ \ __/| \ \ \/ / /
 \ \ \/ / / \ \ \_|/_\ \ _ _\ \ \ \ \ \ \_|/__ \ \ / /
  \ \ / / \ \ \_|\ \ \ \\ \| \ \ \ \ \ \_|\ \ / \/
   \ \__/ / \ \_______\ \__\\ _\ \ \__\ \ \_______\/ /\ \
    \|__|/ \|_______|\|__|\|__| \|__| \|_______/__/ /\ __\
        |__|/ \|__|

 ________ ___ ___ ________ ________ _______ ________
|\ ____\|\ \|\ \|\ __ \|\ ___ \|\ ___ \ |\ __ \
\ \ \___|\ \ \\\ \ \ \|\ \ \ \_|\ \ \ __/|\ \ \|\ \
 \ \_____ \ \ __ \ \ __ \ \ \ \\ \ \ \_|/_\ \ _ _\
  \|____|\ \ \ \ \ \ \ \ \ \ \ \_\\ \ \ \_|\ \ \ \\ \|
    ____\_\ \ \__\ \__\ \__\ \__\ \_______\ \_______\ \__\\ _\
   |\_________\|__|\|__|\|__|\|__|\|_______|\|_______|\|__|\|__|
   \|_________|

 ________ ________ _________
|\ __ \|\ __ \|\___ ___\
\ \ \|\ \ \ \|\ \|___ \ \_|
 \ \ __ \ \ _ _\ \ \ \
  \ \ \ \ \ \ \\ \| \ \ \
   \ \__\ \__\ \__\\ _\ \ \__\
    \|__|\|__|\|__|\|__| \|__|

*/

vec3 gSunColor = vec3(1.0, 1.2, 1.4) * 10.1;

vec3 gSkyTop = vec3( 0.1, 0.2, 0.8 ) * 0.5;
vec3 gSkyBottom = vec3( 0.5, 0.8, 1.0 ) * 1.5;

vec3 gCubeColor = vec3(1.0, 1.0, 1.0);
float gExposure = 0.3;

float gCubeColorRandom = 0.0;

#define MOVE_OUTWARDS

float fAOAmount = 0.8;
float gFloorHeight = -1.0;
float g_cameraFar = 1000.0;

#define PI radians( 180.0 )

vec3 GetSunDir()
{
   return normalize( vec3( 30.0, 40.3, -10.4 ) );
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
const float g_cubeFaces = 6.0;
const float g_cubeVerticesPerFace = ( 2.0 * 3.0 );
const float g_cubeVertexCount = ( g_cubeVerticesPerFace * g_cubeFaces );

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
   float f = fVertexIndex / 8.0;
 return vec3(
      mix(-1., 1., step(0.5, fract(f * 4.))),
      mix(-1., 1., step(0.5, fract(f * 2.))),
      mix(-1., 1., step(0.5, fract(f))));
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
   v0 = (mat * vec4(v0, 1)).xyz;
   v1 = (mat * vec4(v1, 1)).xyz;
   v2 = (mat * vec4(v2, 1)).xyz;
   v3 = (mat * vec4(v3, 1)).xyz;

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
   vec3 vSkyLight = normalize( vec3( -1.5, -2.0, -0.5 ) );

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

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
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

float easeInOutCubic(float pos) {
  if (pos < 0.5) {
    return 0.5 * pow(pos / 0.5, 3.);
  }
  pos -= 0.5;
  pos /= 0.5;
  pos = 1. - pos;
  return (1. - pow(pos, 3.)) * 0.5 + 0.5;
}

float inOut(float v) {
  float t = fract(v);
  if (t < 0.5) {
    return easeInOutCubic(t / 0.5);
  }
  return easeInOutCubic(2. - t * 2.);
}

const float perBlock = 4.;

vec3 getRandomCubePoint(float seed) {
  vec3 p = vec3(
    m1p1(hash(seed)),
    m1p1(hash(seed * 0.731)),
    m1p1(hash(seed * 1.319)));
  float axis = hash(seed * 0.911) * 3.;
  if (axis < 1.) {
    p[0] = mix(-1., 1., step(0., p[0]));
  } else if (axis < 2.) {
    p[1] = mix(-1., 1., step(0., p[1]));
  } else {
    p[2] = mix(-1., 1., step(0., p[2]));
  }
  return p;
}

void GetCubePosition( float fCubeId, float numCubes, out mat4 mat, out vec4 vCubeCol )
{
   float fSeed = fCubeId;
   float fPositionBase = fCubeId;
   float fSize = 1.0;

   vec3 vCubeOrigin = vec3( 0.0, 0.0, 0.0 );

    float across = 48.;
    float down = floor(numCubes / across);
    float uId = mod(fCubeId, across);
    float vId = floor(fCubeId / across);
    float u = uId / (across);
    float v = vId / down;
    float bxId = floor(uId / perBlock);
    float bzId = floor(vId / perBlock);
    float numRows = floor(numCubes / across);
    float numBlocks = floor(numRows / perBlock);

    float uP = m1p1(u);
    float vP = m1p1(v);

    float ll = length(vec2(uP, vP * .5));
    //float s2 = 0.;texture(sound, vec2(mix(0.02, 0.04, hash(u + v + 2.34)), hash(v) * 0.05)).r;

    //vCubeOrigin.x += uP * across * 1.2 + bxId * 0. ;
    float vSpace = numRows * 1.4 + numBlocks * 0.;
    float z = vP * down * 1.4 + bzId * 0.;
    //vCubeOrigin.z += z;
    float height = 1.;
    //vCubeOrigin.y += pow(sin(time + v * 9.), 1.) * pow(cos(time + u * 8.17), 1.) * 4. * inOut(time * 0.1);
    vCubeOrigin = getRandomCubePoint(fCubeId * 0.177);
    vec3 ax = (rotZ(PI * 0.25) * rotY(PI * 0.25) * vec4(vCubeOrigin, 1)).xyz;
    vCubeOrigin += (vec3(hash(fCubeId * 0.317), hash(fCubeId * 0.591), hash(fCubeId * 0.781)) * 2. - 1.) * 0.01;
    //vCubeOrigin += sign(vCubeOrigin);
    vCubeOrigin *= 32.0;

    float ps = p1m1(atan(ax.y, ax.z) / PI);
    float snd = texture(sound, vec2(mix(0.006, 0.019, ps), p1m1(ax.x / 1.4142) * 0.5)).r;
    float beat = 0.;texture(sound, vec2(0.007, 0)).r;

    vCubeOrigin += normalize(vec3(PI * 0.25, PI * .25, 0)) * snd * -8.;

    mat = ident();
    mat *= trans(vCubeOrigin + sign(normalize(vCubeOrigin)) * pow(snd, 5.) * -0.);
    mat *= rotZ(p1m1(snd) * 20.);
    mat *= rotY(p1m1(snd) * 20.);
    mat *= uniformScale(mix(1.5, 1.5, pow(clamp(mix(-0.5, 1., snd), 0., 1.), 7.)));

   vec3 vRandCol;

    float st = step(0.9, snd);
    float h = floor(time * 0.1) * 0.1 + easeInOutCubic(fract(time * 0.1)) * 0.1;
    vCubeCol.rgb = hsv2rgb(vec3(mix(h, h, st),
      0.3, //st,//pow(snd, 0.),
      pow(snd, 5.)));
    // vCubeCol.rgb = mix(vCubeCol.rgb, vec3(1,-20,0), step(0.9, snd));
    vCubeCol.rgb = mix(vCubeCol.rgb, vec3(1,0,5.-snd), step(mix(0.9, 0.55, ps), snd));
    vCubeCol.a =1.- snd;vCubeOrigin.z / vSpace;
}

float goop(float t) {
  return sin(t) * sin(t * 0.27) * sin(t * 0.13) * sin(t * 0.73);
}

void main()
{
   SceneVertex sceneVertex;

   float fov = 1.8;

// vec3 vCameraTarget = vec3( 300, -400.6, 500.0 );
// vec3 vCameraPos = vec3(-45.1, 20., -0.);

   vec3 vCameraTarget = vec3( sin(time * 0.13) * -20., -20., sin(time * 0.13) * -20.0 );
   vec3 vCameraPos = vec3(5) + vec3(sin(time * 0.1) * 7., sin(time * 0.17) * 7., cos(time * 0.1) * 7.0);
    float ca = 0.;

 // get sick!
    ca = time * 0.1;
   vec3 vCameraUp = vec3( mouse.y, 1, mouse.x);

   vec3 vCameraForwards = normalize(vCameraTarget - vCameraPos);

   float vertexIndex = vertexId;

    float fCubeId = floor( vertexIndex / g_cubeVertexCount );
    float fCubeVertex = mod( vertexIndex, g_cubeVertexCount );
    float fNumCubes = floor( vertexCount / g_cubeVertexCount );

    mat4 mCube;
    vec4 vCubeCol;

    GetCubePosition( fCubeId, fNumCubes, mCube, vCubeCol );

    GenerateCubeVertex( fCubeVertex, mCube, vCubeCol.xyz, vCameraPos, sceneVertex );

    mat4 m = persp(radians(90.), resolution.x / resolution.y, 0.1, 100.);
    m *= cameraLookAt(vCameraPos, vCameraTarget, vCameraUp);
    gl_Position = m * vec4(sceneVertex.vWorldPos, 1);

   // Final output color
   float fExposure = gExposure;//min( gExposure, sin( time * 0.21) );
   vec3 vFinalColor = sqrt( vec3(1.0) - exp2( sceneVertex.vColor * -fExposure ) );

   v_color = mix(vec4(vFinalColor, 1), background, vCubeCol.a);

}
// Removed built-in GLSL functions: transpose, inverse