/*{
  "DESCRIPTION": "shadow_test",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/LLTEjXA7Q49X7GMMm)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 24579,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.403921568627451,
    0.403921568627451,
    0.403921568627451,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 62,
    "ORIGINAL_DATE": {
      "$date": 1582495761214
    }
  }
}*/


/*

        .___ __ .
        [__ . , _.._ / `|_ _ ._
        [___ \/ (_][ )____\__.[ )(/,[ )

01/01/2019
@BestRegard
*/

#define COLOR_SUNSET

#ifdef COLOR_PASTEL

vec3 gSunColor = vec3(1.0, 0.9, 0.1) * 10.0;

vec3 gSkyTop = vec3( 0.1, 0.2, 0.8 ) * 4.0;
vec3 gSkyBottom = vec3( 0.5, 0.8, 1.0 ) * 5.0;

float gFogDensity = 0.01;

 vec3 gFloorColor = vec3(0.5, 0.1, 0.2);
vec3 gCubeColor = vec3(1.0, 0.8, 0.8);
float gExposure = 1.0;

float gCubeColorRandom = 0.4;

#endif

#ifdef COLOR_VIVID

vec3 gSunColor = vec3(1.0, 0.9, 0.1) * 10.0;

vec3 gSkyTop = vec3( 0.1, 0.2, 0.8 ) * 0.5;
vec3 gSkyBottom = vec3( 0.5, 0.8, 1.0 ) * 1.5;

float gFogDensity = 0.05;

 vec3 gFloorColor = vec3(0.5, 0.1, 0.2);
vec3 gCubeColor = vec3(1.0, 0.1, 1.0);
float gExposure = 1.0;

float gCubeColorRandom = 0.9;

#endif

#pragma region Pre_Define
 #define PI radians(180.)
#pragma endregion

#pragma region const
 const float FARCLIPPED = 1000. ;
 const float NEARCLIPPED = 0.1 ;
    float g_cameraFar = 1000.0;

#pragma endregion

#pragma region MatrixConverte

  mat4 mAspect = mat4
  (
    1, 0, 0, 0,
    0, resolution.x / resolution.y, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
  );
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

#pragma region

#pragma region Func
   mat4 cameraLookAt(vec3 eye, vec3 target, vec3 up)
   {
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
  // hash function from https://www.shadertoy.com/view/4djSRW
  float hash(float p)
  {
      vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
      p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
      return fract(p2.x * p2.y * 95.4337);
  }

  float m1p1(float v) //normalize to NDC
  {
    return v * 2. - 1.;
  }

  float inv(float v)
  {
    return 1. - v;
  }

#pragma endregion

#pragma region Scene_Vertex_Collection d
  struct SceneVertex
  {
      vec3 vWorldPos;
      vec3 vColor;
      float fAlpha;
  };

  struct SurfaceInfo
  {
      vec3 vPos;
      vec3 vNormal;
      float fGloss;
  };
  struct SphereInfo
  {
      vec3 vOrigin;
      float fRadius ;

      float fSlices ;
      float fSegments ;
  };

  struct Material
  {
      vec4 diffuseAlebdo;
      vec3 FresenlR0 ;
      float Roughness ;
      mat4 MatTransform ;
  };
  struct Light
  {

      vec3 vStrength ;
      float FalloffStart ;
      vec3 vDirection ;
      float FalloffEnd ;
      vec3 vPosition ;
      float SpotPower ;
  };
#pragma endregion

#pragma region GetInfo

vec3 GetSunDir()
{
   return normalize( vec3( 1.0, 0.3, -0.5 ) );
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

void GetQuadInfo(const float vertexIndex,
        out vec2 quadVertId,

        out float quadId )
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

void GetQuadTileInfo(const vec2 quadVertId,
        const float quadId,
        const vec2 vDim,

        out vec2 vQuadTileIndex,
        out vec2 vQuadUV )
{
    vQuadTileIndex.x = floor( mod( quadId, vDim.x ) );
    vQuadTileIndex.y = floor( quadId / vDim.x );

   vQuadUV.x = floor(quadVertId.x + vQuadTileIndex.x);
    vQuadUV.y = floor(quadVertId.y + vQuadTileIndex.y);

    vQuadUV = vQuadUV * (1.0 / vDim);
}

void GetQuadTileInfo(const float vertexIndex,
        const vec2 vDim,

        out vec2 vQuadTileIndex,
        out vec2 vQuadUV )
{
   vec2 quadVertId;
   float quadId;
 GetQuadInfo( vertexIndex, quadVertId, quadId );
   GetQuadTileInfo( quadVertId, quadId, vDim, vQuadTileIndex, vQuadUV );
}

float GetCosSunRadius()
{
  return 0.01;
}

float GetSunIntensity()
{
   return 0.001;
}

vec3 GetNormalToWorld(SphereInfo in_SI, vec3 in_Normal)
{
  return in_Normal ;
}
vec3 GetPosToWorld(SphereInfo in_SI, vec3 vPos)
{
  return in_SI.vOrigin + vPos ;
}
float GetSphereQuadCount(const SphereInfo in_SI)
{
    return in_SI.fSegments * in_SI.fSlices;
}
float GetSphereVertexCount(const SphereInfo in_SI)
{
    return GetSphereQuadCount(in_SI) * 6.;
}

vec3 GetSunPosition()
{
   float fSunDistance = 140.0;
   return vec3( 0.0, 0.3, 1.0 ) * fSunDistance;
}
vec3 GetSunDir( vec3 vCameraPos )
{
   return normalize( GetSunPosition() - vCameraPos );
}

// From Shadertoy "Hash without sine - Dave Hoskins"
// https://www.shadertoy.com/view/4djSRW
#define MOD3 vec3(.1031,.11369,.13787)
#define MOD4 vec4(.1031,.11369,.13787, .09987)
float hash11(float p)
{
 vec3 p3 = fract(vec3(p) * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

vec4 hash41(float p)
{
 vec4 p4 = fract(vec4(p) * MOD4);
    p4 += dot(p4, p4.wzxy+19.19);
    return fract(vec4((p4.x + p4.y)*p4.z, (p4.x + p4.z)*p4.y, (p4.y + p4.z)*p4.w, (p4.z + p4.w)*p4.x));

}
float SmoothNoise(in vec2 o)
{
 vec2 p = floor(o);
 vec2 f = fract(o);

 float n = p.x + p.y*57.0;

 float a = hash11(n+ 0.0);
 float b = hash11(n+ 1.0);
 float c = hash11(n+ 57.0);
 float d = hash11(n+ 58.0);

 vec2 f2 = f * f;
 vec2 f3 = f2 * f;

 vec2 t = 3.0 * f2 - 2.0 * f3;

 float u = t.x;
 float v = t.y;

 float res = a + (b-a)*u +(c-a)*v + (a-b+d-c)*u*v;

    return res;
}

//FBM step
#define k_fmbSteps 10
float FBM( vec2 p, float repeat, float ps ) {
 float f = 0.0;
    float tot = 0.0;
    float a = 1.0;
    for( int i=0; i<k_fmbSteps; i++)
    {
        f += SmoothNoise( fract(p / repeat) * repeat ) * a;
        p *= 2.0;
        tot += a;
        a *= ps;
    }
    return f / tot;
}
#pragma endregion

#pragma region HelperMethod
float saturate(float v1)
{
  return clamp(v1 , 0.0 , 1.0);
}

float CalAttenuation(float d, float falloffStart, float falloffEnd)
{
  return saturate( (falloffEnd -d ) / (falloffEnd - falloffStart) );
}

vec3 SchlickFresnel(vec3 R0 , vec3 normal , vec3 lightVec )
{
  float cosIncidentAngle = saturate(dot(normal , lightVec)) ;

  float f0 = 1.0 - cosIncidentAngle ;

  vec3 reflectPercent = R0 + (1.0 - R0) * (f0*f0*f0*f0*f0) ;

  return reflectPercent;
}
/*
directx code:MSDN

float3 result = saturate(texCol0.rgb - Density*(texCol1.rgb));

GLSL equivalent:

vec3 result = clamp(texCol0.rgb - Density*(texCol1.rgb), 0.0, 1.0);
*/

vec3 BlinnPhong(vec3 lightStrength, vec3 lightVec ,
        vec3 normal, vec3 toEye, Material mat)
{
  float m = (1. - mat.Roughness) * 256.0 ;
  vec3 halfVec = normalize(toEye + lightVec);

  float roughnessFactor = (m + 8.0) *
        pow(max(dot(halfVec , normal), 0.0 ), m) / 8.0;
  vec3 fresnelFactor = SchlickFresnel(mat.FresenlR0 , halfVec , lightVec);

  return mat.diffuseAlebdo.rgb * lightStrength ;
}

void Shadow(inout vec3 color)
{
  color -= vec3(0.2 , 0.2 , 0.2) ;
}

#pragma endregion

#pragma region PostEffect
//https://blog.csdn.net/qq_29601003/article/details/103696527
  void PE_Vignette(inout SceneVertex out_SV)
  {
    float dist = distance(out_SV.vWorldPos.xy, vec2(0.5)) * 2.0 ;
    dist /= 1.5142;
    dist = pow(dist, 1.1) ;
    out_SV.vColor *= (1.0 - dist) ;
  }
#pragma endregion

#pragma region Light/Shadow
  //Directional Light
  vec3 ComputeDirLight(Light L, Material mat,
        vec3 pos ,vec3 normal, vec3 toEye)
  {
    vec3 lightVec = -L.vDirection ;

    float ndotl = max(dot(lightVec , normal) , 0. ) ;
    vec3 lightStrength = L.vStrength * ndotl ;

    return BlinnPhong(lightStrength , lightVec, normal , toEye , mat) ;
  }
#pragma endregion

#pragma region InfoCollection
/*DirLight*/

  #define DirStrength vec3(0.4 , 0.4 , 0.4 )
  #define DirFalloffStart 1.
  #define DirDirection vec3(-0.4, -2. , 1. )
  #define DirPosition vec3(0.)
  #define DirSpotPower 12.

  #define SphSegments 64.
  #define SphSclices 48.
  #define SphOrigin vec3(0.)
  #define SphRdius 5.

#pragma endregion

#pragma region DrawScreen
    #define WidthX 16.0
    #define HeightY 16.0
    #define floorTileCount (WidthX * HeightY)
    #define floorVertexCount (floorTileCount * 6.)
    void GenFloor(const vec3 in_ViewPos, const float vertexIndex,
        const Light in_light,
        inout SceneVertex outSceneVertex )
    {
  vec2 vDim = vec2( WidthX, HeightY );
        vec2 vQuadTileIndex;
  vec2 vQuadUV;
      /*Get the Current TileInfo*/
  GetQuadTileInfo( vertexIndex, vDim, vQuadTileIndex, vQuadUV );
        outSceneVertex.vWorldPos.xz = (vQuadUV * 2.0 - 1.0) * 100.0;
  outSceneVertex.vWorldPos.y = 0.;
  outSceneVertex.fAlpha = 1.0;
  outSceneVertex.vColor = vec3(0.);

  vec3 vNormal = vec3( 0.0, 1.0, 0.0 );
      /*Get the Surface Info*/
       SurfaceInfo s_FloorS ;
       s_FloorS.vPos = outSceneVertex.vWorldPos ;
       s_FloorS.vNormal = vNormal ;
       s_FloorS.fGloss = 5. ;
      /*Set the Material Info*/
       Material mat;
       mat.diffuseAlebdo = vec4(0.5 ,0.8 ,0.8, 1.0);
       mat.FresenlR0 = vec3(0.1 , 0.1, 0.1 ) ;
        mat.Roughness = 0.125 ;

      /*Apply the lgiht*/
       vec3 result = vec3(0.) ;
        vec3 toEye = normalize((in_ViewPos - outSceneVertex.vWorldPos)) ;
        result = ComputeDirLight(in_light , mat ,
        outSceneVertex.vWorldPos , vNormal , toEye);
        result *= 2.72 / ( log(distance(in_ViewPos.x, outSceneVertex.vWorldPos.x))) ;
      /*Apply the Shadow*/
       vec3 m = outSceneVertex.vWorldPos + DirDirection;
       vec3 AP = SphOrigin - outSceneVertex.vWorldPos;
       vec3 pp = abs(dot(m, AP)) / abs(m) ;
        vec3 c2l = sqrt(
        pow(AP, vec3(2.)) -
        pow(pp, vec3(2.))
        ) ;
       float disLength = length(c2l);

      /*Apply the Color to hte scene color*/
       outSceneVertex.vColor = result;

      /*Apply the shadow color*/
       if(disLength < SphRdius)
        {
        /*Apply the shadow color*/
        Shadow(outSceneVertex.vColor);
        }

    }
//SunInfo
 #define Sun_fSegments 64.
 #define Sun_fSclices 48.
 #define Sun_vOrigin vec3(0.)
 #define Sun_fRadius 5.
 void GenPointLight(const float in_vertexIndex,
        const Light in_light,
        const vec3 in_CamPos ,
        out SceneVertex outSceneVertex)
    {
      vec2 vDim = vec2(Sun_fSegments , Sun_fSclices);

      vec2 vQuadTileIndex ;
      vec2 vUV ;
      GetQuadTileInfo(in_vertexIndex, vDim ,
        vQuadTileIndex,
        vUV);
       float fElevation = vUV.y * PI ;

    }

 void GenSphere(const float in_vertexIndex,
        const SphereInfo in_SI ,
        const Light in_DL ,
        const vec3 in_CamPos,
        out SceneVertex outSceneVertex)
    {
      vec2 vDim = vec2(in_SI.fSegments , in_SI.fSlices);

      vec2 vQuadTileIndex ;
      vec2 vUV ;
      GetQuadTileInfo(in_vertexIndex, vDim ,
        vQuadTileIndex,
        vUV);

      vec3 vSpherePos ;
      float fElevation = vUV.y * PI ;
      vSpherePos.y = cos(fElevation);
     /*setting up the Heading*/
      float fHeading = vUV.x * PI * 2. ;
      float fSliceRadius = sqrt(1. - vSpherePos.y * vSpherePos.y);
      vSpherePos.x = sin(fHeading ) * fSliceRadius ;
      vSpherePos.z = cos(fHeading ) * fSliceRadius ;

      vec3 vSphereNormal = normalize(vSpherePos);

      vec3 vWorldNormal = GetNormalToWorld(in_SI , vSphereNormal);
      outSceneVertex.vWorldPos = GetPosToWorld(in_SI, vSpherePos * in_SI.fRadius);

      /*Setting up the color view */
      SurfaceInfo t_SI ;
      t_SI.vPos = outSceneVertex.vWorldPos - vec3(0.) ;
      t_SI.vNormal = vWorldNormal ;
      t_SI.fGloss = 5. ;

      /*Material*/
      Material mat;
      mat.diffuseAlebdo = vec4(0.5 ,0.8 ,0.8, 1.0);
      mat.FresenlR0 = vec3(0.1 , 0.1, 0.1 ) ;
      mat.Roughness = 0.125 ;

      /*Apply the lgiht*/
      vec3 result = vec3(0.) ;
      vec3 toEye = normalize((in_CamPos - outSceneVertex.vWorldPos)) ;

      result = ComputeDirLight(in_DL , mat ,
        outSceneVertex.vWorldPos , vSphereNormal , toEye);
      /*apply the light*/
      outSceneVertex.vColor = result ;
      outSceneVertex.fAlpha = 1. ;

    }

#pragma endregion

/* -------------------------------- display ------------------------------- */

/* -------------------------------- display ------------------------------- */
/*
  struct Light
  {
      vec3 vStrength ;
      float FalloffStart ;
      vec3 vDirection ;
      float FalloffEnd ;
      vec3 vPosition ;
      float SpotPower ;
  };
*/
//globalLight
 Light DirLight ; //Directional Light
    Light PointLight; //Point Light
 Light SpotLihgt ; //Spot Light

void main()
{

  DirLight.vStrength = DirStrength ; /*Directional Light*/
  DirLight.FalloffStart = DirFalloffStart ;
  DirLight.vDirection = DirDirection;
  DirLight.vPosition = DirPosition;
  DirLight.SpotPower = DirSpotPower ;

  PointLight.vStrength = vec3(1. , 1. , 1. ) ; /*Point Light*/
  PointLight.FalloffStart = 1. ;
  PointLight.vDirection = vec3(-1., -2., 1.);
  PointLight.vPosition = vec3(4. , 5. , 2.) ;
  PointLight.SpotPower = 32. ;

  #pragma region screenSetting
 SceneVertex sv ;
 vec2 vMouse = mouse ;
   float vertexIndex = vertexId ;
  #pragma endregion

  #pragma region Sphereinfo
   SphereInfo sphereInfo ;
  sphereInfo.fSegments = SphSegments;
    sphereInfo.fSlices = SphSclices;
   sphereInfo.vOrigin = SphOrigin ;
    sphereInfo.fRadius = SphRdius ;
  #pragma endregion

  #pragma region ProjectionSetUp
     mat4 m = persp(radians(60.),
        resolution.x/ resolution.y,
        NEARCLIPPED ,
        FARCLIPPED);
  #pragma endregion

  #pragma region CameraSetUp/ViewSetUp
      vec3 target = vec3(0. ) ;
      vec3 up = vec3(0. ,1. , 0. ) ;
   //target = sv.vWorldPos;
      vec3 camTarget = target ;
      vec3 camPos = vec3(90. ,90. ,0.);
      vec3 camForward = normalize(camTarget - camPos);
      m *= cameraLookAt(camPos , camTarget, normalize(up));
  #pragma endregion

  #pragma region Global Setting
      m *= uniformScale(1.5);
    // m *= trans(vec3(0.)) ;
     // m *= rotY(1. * time);
    //m *= rotZ(sin(1. * time));
  #pragma endregion

#pragma region DrawSomething
  #pragma region Floor
    if(vertexIndex >= 0. && vertexIndex < floorVertexCount)
      GenFloor(camPos , vertexId, DirLight,
        sv) ;
    vertexIndex -= floorVertexCount ;
  #pragma endregion

  #pragma region Sphere
      float fSphereVertexCount = GetSphereVertexCount(sphereInfo);
      if(vertexIndex >= 0. && vertexIndex < fSphereVertexCount)
      {
        GenSphere(vertexIndex, sphereInfo,
        DirLight,
        camPos,
        sv);
        m *= uniformScale(1.5);
        m *= trans(vec3(0. , 4. , 0. )) ;
      }
      vertexIndex -= fSphereVertexCount ;
  #pragma endregion
#pragma endregion

#pragma region PostEffect
 // PE_Vignette(sv) ;
#pragma endregion

#pragma region ApplySetting
    gl_Position = m * vec4(sv.vWorldPos, 1.);
   gl_PointSize = 10. ;
    v_color = vec4(sv.vColor * sv.fAlpha, sv.fAlpha);
#pragma endregion
}
// Removed built-in GLSL functions: transpose, inverse