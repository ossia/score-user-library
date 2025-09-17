/*{
  "DESCRIPTION": "adv_Sphere",
  "CREDIT": "evan_chen (ported from https://www.vertexshaderart.com/art/L6xDZ78mbnpnMQGQj)",
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
    0.403921568627451,
    0.403921568627451,
    0.403921568627451,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 202,
    "ORIGINAL_DATE": {
      "$date": 1578542289768
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

#pragma region Scene_Vertex_Collection
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
   float fSunDistance = 14000.0;
   return vec3( 0.0, 0.1, 1.0 ) * fSunDistance;
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

#pragma region DrawScreen
    #define WidthX 16.0
    #define HeightY 16.0
    #define floorTileCount (WidthX * HeightY)
    #define floorVertexCount (floorTileCount * 6.)

    #define aStrength 1.
    #define dStrength 0.9
    #define sStrength 1.
    #define vLightPos vec3(0, 20, 0.)
    #define vSunColor vec3( 1.0, 0.8, 0.5 ) * 100.0
    #define vFloorColor vec3(0.9, 0.8, 0.6)
 void ApplyLightC(const vec3 viewPos , vec3 in_normal , vec3 in_Pos,
        inout vec3 in_Color )
    {
      vec3 lightD = GetSunDir() ;
      vec3 lightC = vSunColor ;
      vec3 lightP = vLightPos ;
      /*ambient*/
   vec3 ambient = lightC * aStrength ;
      /*diffuse*/
      vec3 l2SD = normalize(vLightPos - in_Pos);
      float diff = max( dot(in_normal , l2SD), 0.);
      vec3 diffuse = diff * dStrength * lightC;
      /*specular*/
      vec3 viewD = normalize(viewPos - in_Pos);
      vec3 refDir = reflect(-l2SD , in_normal);
   float spec = pow(max(dot(refDir , viewPos), 0.) , 64.0) ;
      vec3 specualr = spec * sStrength * lightC ;
      in_Color += ambient + diffuse + specualr ;
      in_Color += vFloorColor ;
    }
    void AddDirectionalLight(vec3 vLightDir, vec3 vLightColor,const SurfaceInfo in_SI, const vec3 vCameraPos,
        inout vec3 vDiffuse,
        inout vec3 vSpecualr)
    {
      vec3 vViewDir = normalize(vCameraPos - in_SI.vPos) ;

      float normalDotLihgtDir = max(0. , dot(vLightDir, in_SI.vPos));

      vec3 vHalfAngle = normalize(vViewDir + vLightDir);

      float normalDotheight = max(0. , dot(vHalfAngle, in_SI.vNormal)) ;

      vDiffuse += normalDotLihgtDir * vLightColor ;

      float fPower = in_SI.fGloss ;

      vSpecualr += pow( normalDotheight, fPower) *2. * normalDotLihgtDir * vLightColor;
    }
  vec3 LightSurface(const SurfaceInfo in_SI,
        const vec3 vCamerapos,
        const vec3 vAlbedo, const float fShadow )
    {
      vec3 vDiffuseLight = vec3(0.) ;
      vec3 vSpecLight = vec3(0.) ;

      AddDirectionalLight(GetSunDir(vCamerapos) , vSunColor * 0.01 * fShadow,
        in_SI, vCamerapos,
        vDiffuseLight, vSpecLight);

      vec3 vViewDir = normalize(vCamerapos - in_SI.vPos ) ;

      float fNdotD = clamp(dot(in_SI.vNormal, vViewDir) , 0. , 1.) ;
      vec3 vR0 = vec3(0.04) ;
      vec3 vFresnel = vR0 + (1.0 - vR0) * pow(1.0 - fNdotD, 5.0);

    vec3 vColor = mix( vDiffuseLight * vAlbedo, vSpecLight, vFresnel );

      return vColor;
    }
 void GenSunSphere(const vec3 in_VertexId, const vec3 in_ViewPos, inout SceneVertex out_SceneVertex)
    {

    }

    void GenFloor( const vec3 in_ViewPos, const float vertexIndex, inout SceneVertex outSceneVertex )
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
      /*Apply the Color to hte scene color*/
       ApplyLightC(in_ViewPos , s_FloorS.vNormal , s_FloorS.vPos , outSceneVertex.vColor) ;
    }

 #define f_Segments 64.
 #define f_Slices 48.
 #define f_Origin vec3(0.)
 #define f_Radius 5.
 void GenSphere(const float in_vertexIndex, const SphereInfo in_SI , const vec3 in_CamPos,
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
      t_SI.vPos = outSceneVertex.vWorldPos ;
      t_SI.vNormal = vWorldNormal ;
      t_SI.fGloss = 5. ;

      /*apply the light*/
     // outSceneVertex.vColor = LightSurface(t_SI, in_CamPos, vec3(1.), 1.); ;
      outSceneVertex.vColor = vec3(vWorldNormal) ;
      outSceneVertex.fAlpha = 1. ;

    }
#pragma endregion

/* -------------------------------- display ------------------------------- */

/* -------------------------------- display ------------------------------- */

void main()
{
  #pragma region screenSetting
 SceneVertex sv ;
 vec2 vMouse = mouse ;
   float vertexIndex = vertexId ;
  #pragma endregion

  #pragma region Sphereinfo
   SphereInfo sphereInfo ;
  sphereInfo.fSegments = 64. ; //设置面数
    sphereInfo.fSlices = 48. ; // 设置细节
    sphereInfo.vOrigin = vec3(0. ) ; //设置起始位置
    sphereInfo.fRadius = 5. ; //设置半径
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

  #pragma region model
      m *= uniformScale(10.);
    // m *= trans(vec3(0.)) ;
      m *= rotY(1. * time);
    //m *= rotZ(sin(1. * time));
  #pragma endregion

  #pragma region Start to draw something
/*
    if(vertexIndex >= 0. && vertexIndex < floorVertexCount)
      GenFloor(camPos , vertexId, sv) ;
    vertexIndex -= floorTileCount ;
 */
  /*draw the sphere*/
   float fSphereVertexCount = GetSphereVertexCount(sphereInfo);
    if(vertexIndex >= 0. && vertexIndex < fSphereVertexCount)
    {
      GenSphere(vertexIndex, sphereInfo, camPos,
        sv);
    }
   vertexIndex -= fSphereVertexCount ;

  #pragma endregion

  #pragma region add to glsl

    gl_Position = m * vec4(sv.vWorldPos, 1.);
   gl_PointSize = 10. ;
    v_color = vec4(sv.vColor * sv.fAlpha, sv.fAlpha);
  #pragma endregion
}
// Removed built-in GLSL functions: transpose, inverse