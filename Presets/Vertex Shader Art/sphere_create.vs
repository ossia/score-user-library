/*{
  "DESCRIPTION": "sphere create ",
  "CREDIT": "evan_chen (ported from https://www.vertexshaderart.com/art/b9J4bEZw9Z2qRJm5f)",
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
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_DATE": {
      "$date": 1578398393611
    }
  }
}*/

// Planet Polygon - @P_Malin

// Switch the primitive type to LINES to see how the background sun flare is rendered!

float g_cameraFar = 8000.0;

vec3 g_sunColor = vec3( 1.0, 0.8, 0.5 ) * 100.0;

#define PI radians( 180.0 )

vec3 GetSunPosition()
{
   float fSunDistance = 14000.0;
   return vec3( 0.0, 0.1, 1.0 ) * fSunDistance;
}

vec3 GetSunDir( vec3 vCameraPos )
{
   return normalize( GetSunPosition() - vCameraPos );
}

float GetCosSunRadius( vec3 vCameraPos )
{
   float d = length( vCameraPos - GetSunPosition() );
   return 100.0 / d;
}

float GetSunIntensity( vec3 vCameraPos )
{
   float d = length( vCameraPos - GetSunPosition() );
   return 1000.0 / (d * d);
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

struct SurfaceInfo
{
 vec3 vPos;
   vec3 vNormal;
 float fGloss;
};

void AddDirectionalLight( vec3 vLightDir, vec3 vLightColor, const SurfaceInfo surfaceInfo, const vec3 vCameraPos, inout vec3 vDiffuse, inout vec3 vSpecular )
{
  vec3 vViewDir = normalize(vCameraPos-surfaceInfo.vPos);

  float NdotL = max( 0.0, dot( vLightDir, surfaceInfo.vNormal ) );

  vec3 vHalfAngle = normalize( vViewDir + vLightDir );

  float NdotH = max( 0.0, dot( vHalfAngle, surfaceInfo.vNormal ) );

  vDiffuse += NdotL * vLightColor;

  float fPower = surfaceInfo.fGloss;
  vSpecular += pow( NdotH, fPower ) * 2.0 * NdotL * vLightColor;
}

vec3 LightSurface( const SurfaceInfo surfaceInfo, const vec3 vCameraPos, const vec3 vAlbedo, float fShadow )
{
  vec3 vDiffuseLight = vec3(0.0);
  vec3 vSpecLight = vec3(0.0);

  AddDirectionalLight( GetSunDir(vCameraPos), g_sunColor * 0.01 * fShadow, surfaceInfo, vCameraPos, vDiffuseLight, vSpecLight );

  vec3 vViewDir = normalize(vCameraPos-surfaceInfo.vPos);

  float fNdotD = clamp(dot(surfaceInfo.vNormal, vViewDir), 0.0, 1.0);
  vec3 vR0 = vec3(0.04);
  vec3 vFresnel = vR0 + (1.0 - vR0) * pow(1.0 - fNdotD, 5.0);

  vec3 vColor = mix( vDiffuseLight * vAlbedo, vSpecLight, vFresnel );

  return vColor;
}

vec3 PostProcess( vec3 vColor, float fExposure )
{
  vColor = vec3(1.0) - exp2( vColor * -fExposure );

  vColor = pow( vColor, vec3(1.0 / 2.2) );

  return vColor;
}

vec3 ApplyVignetting( const in vec2 vUV, const in vec3 vInput )
{
 vec2 vOffset = (vUV - 0.5) * sqrt(2.0);

 float fDist = dot(vOffset, vOffset);

 const float kStrength = 0.95;
 const float kPower = 1.5;

 return vInput * ((1.0 - kStrength) + kStrength * pow(max(0.0, 1.0 - fDist), kPower));
}

struct SceneVertex
{
   vec3 vWorldPos;
   vec3 vColor;
 float fAlpha;
};

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

vec3 GetBackdropColor( vec3 vViewDir, vec3 vCameraPos )
{
   float VdotL = dot( normalize(vViewDir), GetSunDir(vCameraPos) );

   VdotL = clamp( VdotL, 0.0, 1.0 );

   float fShade = 0.0;

   fShade = acos( VdotL ) * (1.0 / PI);

   float fCosSunRadius = GetCosSunRadius(vCameraPos);

   fShade = max( 0.0, (fShade - fCosSunRadius) / (1.0 - fCosSunRadius) );

   fShade = GetSunIntensity( vCameraPos ) / pow(fShade, 1.5);

    return vec3( fShade * g_sunColor );
}

#define g_backdropSegments 32.0
#define g_backdropSlices 32.0
#define g_backdropQuads ( g_backdropSegments * g_backdropSlices )
#define g_backdropVertexCount ( g_backdropQuads * 6.0 )

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

#define g_starCount 3000.0
#define g_starSegments 6.0
#define g_verticesPerStar ( g_starSegments * 3.0 )
#define g_starVertexCount ( g_starCount * g_verticesPerStar )

void GenerateStarVertex( const float vertexIndex, const vec3 vCameraPos, out SceneVertex outSceneVertex )
{
 float fStarIndex = floor( vertexIndex / g_verticesPerStar );

   vec4 vRandom = hash41(fStarIndex);
   vec3 vStarPos = normalize( vRandom.xyz * 2.0 - 1.0 );

    float fBrightness = 0.25 / (0.5 + vRandom.w * 20.0);

   float fStarVertexIndex = mod( vertexIndex, g_verticesPerStar );
   float fSegmentIndex = floor( fStarVertexIndex / 3.0 );
   float fTriVertexIndex = mod( fStarVertexIndex, 3.0 );

   float fAngle0 = (fSegmentIndex + 0.0) * PI * 2.0 / g_starSegments;
   float fAngle1 = (fSegmentIndex + 1.0) * PI * 2.0 / g_starSegments;

   vec3 vData;

   if ( fTriVertexIndex < 0.5 ) vData = vec3( 0.0, 0.0, 1.0 );
    else if ( fTriVertexIndex < 1.5 ) vData = vec3( sin(fAngle0), cos(fAngle0), 0.0 );
   else vData = vec3( sin(fAngle1), cos(fAngle1), 0.0 );

   float fSize = 15.0;
    vec3 vOffset = vec3( vData.x, vData.y, 0.0 ) * fSize;
    float fAlpha = vData.z;

   mat3 m;
   GetMatrixFromZ( vStarPos, m );

    outSceneVertex.vWorldPos = m * vOffset;
    outSceneVertex.vWorldPos += vStarPos * (g_cameraFar - 200.0);
   outSceneVertex.vWorldPos += vCameraPos;

    vec3 vBackdropColor = GetBackdropColor(outSceneVertex.vWorldPos - vCameraPos, vCameraPos);

   outSceneVertex.vColor = vBackdropColor + fAlpha * fBrightness;

   outSceneVertex.fAlpha = 1.0;
}

struct PlanetInfo
{
 vec3 vSurfaceColor0;
 vec3 vSurfaceColor1;
   float textureScale;
    float texturePersistence;
   float surfaceType;

   vec3 vRingColor0;
 vec3 vRingColor1;
   bool hasRings;

   vec3 vOrigin;
   float fRadius;

   float fSegments;
   float fSlices;

   int iMoonCount;
};

vec3 PlanetPosToWorld( PlanetInfo planetInfo, vec3 vPos )
{
 return planetInfo.vOrigin + vPos;
}

vec3 PlanetNormalToWorld( PlanetInfo planetInfo, vec3 vNormal )
{
 return vNormal;
}

float GetPlanetQuadCount( PlanetInfo planetInfo )
{
   return planetInfo.fSegments * planetInfo.fSlices;
}

float GetPlanetVertexCount( PlanetInfo planetInfo )
{
   return GetPlanetQuadCount( planetInfo ) * 6.0;
}

void GeneratePlanetVertex( const float vertexIndex, const vec3 vCameraPos, PlanetInfo planetInfo, out SceneVertex outSceneVertex )
{
    vec2 vDim = vec2( planetInfo.fSegments, planetInfo.fSlices );

   vec2 vQuadTileIndex;
    vec2 vUV;
   GetQuadTileInfo( vertexIndex, vDim, vQuadTileIndex, vUV );

   vec3 vSpherePos;
   float fElevation = vUV.y * PI;
   vSpherePos.y = cos( fElevation );

   float fHeading = vUV.x * PI * 2.0;
   float fSliceRadius = sqrt( 1.0 - vSpherePos.y * vSpherePos.y );
   vSpherePos.x = sin( fHeading ) * fSliceRadius;
   vSpherePos.z = cos( fHeading ) * fSliceRadius;

   vec3 vPlanetNormal = normalize( vSpherePos );
   //vec3 vPlanetSpherePos = vSpherePos * planetInfo.fRadius;

   vec3 vWorldNormal = PlanetNormalToWorld( planetInfo, vPlanetNormal );
    outSceneVertex.vWorldPos = PlanetPosToWorld( planetInfo, vSpherePos * planetInfo.fRadius );

   SurfaceInfo surfaceInfo;
   surfaceInfo.vPos = outSceneVertex.vWorldPos;
   surfaceInfo.vNormal = vWorldNormal;
   surfaceInfo.fGloss = 5.0;

    outSceneVertex.vColor = LightSurface( surfaceInfo, vCameraPos, vec3(0.1), 1.0 );
 //outSceneVertex.vColor = vec3(1.) ;
   outSceneVertex.fAlpha = 1.0;
}

float GetPlanetShadow( vec3 vPos, vec3 vCameraPos, PlanetInfo planetInfo )
{
   float fShadowAttn = 1.0;

   vec3 vSphereOrigin = PlanetPosToWorld( planetInfo, vec3(0.0) );
   float fSphereRadius = planetInfo.fRadius;

   vec3 vRayOrigin = vPos;
   vec3 vRayDir = GetSunDir(vCameraPos);

 vec3 vToOrigin = vSphereOrigin - vRayOrigin;
 float fProjection = dot(vToOrigin, vRayDir);
 vec3 vClosest = vRayOrigin + vRayDir * fProjection;

 vec3 vClosestToOrigin = vClosest - vSphereOrigin;
 float fClosestDist2 = dot(vClosestToOrigin, vClosestToOrigin);

 float fSphereRadius2 = fSphereRadius * fSphereRadius;

 if(fClosestDist2 < fSphereRadius2)
 {
  float fHCL = sqrt(fSphereRadius2 - fClosestDist2);

  float fMinDist = fProjection - fHCL;

       if ( (fMinDist >= 0.0) && (fMinDist < 100.0 ) )
        {
        fShadowAttn = (fClosestDist2 - fSphereRadius2) + 10.0;
        fShadowAttn *= 0.025;
        fShadowAttn = clamp( fShadowAttn, 0.0, 1.0);
        }
 }

   return fShadowAttn;
}

#define g_ringSegments 128.0
#define g_ringQuads ( g_ringSegments * 3.0 )
#define g_ringVertexCount ( g_ringQuads * 6.0 )

void GenerateRingVertex( const float vertexIndex, const vec3 vCameraPos, PlanetInfo planetInfo, out SceneVertex outSceneVertex, float fInnerRadius, float fOuterRadius, float fRandom )
{
    vec2 vDim = vec2( g_ringSegments, 3 );

   vec2 vQuadTileIndex;
    vec2 vUV;
   GetQuadTileInfo( vertexIndex, vDim, vQuadTileIndex, vUV );

   vec3 vRingPos;

   float fHeading = vUV.x * PI * 2.0;

   float fRadiusPos = vUV.y;

   if( vUV.y < 0.5 ) fRadiusPos = 0.0; else fRadiusPos = 1.0;

   float fRadius = fInnerRadius + fRadiusPos * (fOuterRadius - fInnerRadius);

   if ( vUV.y < 0.01 ) fRadius-= 0.02;
   if ( vUV.y > 0.99 ) fRadius+= 0.02;

   vRingPos.y = 0.0;
   vRingPos.x = sin( fHeading ) * fRadius;
   vRingPos.z = cos( fHeading ) * fRadius;

    outSceneVertex.vWorldPos = PlanetPosToWorld( planetInfo, vRingPos );

   float fShadow = GetPlanetShadow( outSceneVertex.vWorldPos, vCameraPos, planetInfo );

   float fAlpha = ( fRandom * 0.5 + 0.5);
 fAlpha = fAlpha * fAlpha;

   vec3 vAlbedo = mix( planetInfo.vRingColor0, planetInfo.vRingColor1, fRandom );

    SurfaceInfo surfaceInfo;
   surfaceInfo.vPos = outSceneVertex.vWorldPos;
   surfaceInfo.vNormal = PlanetNormalToWorld( planetInfo, vec3(0.0, 1.0, 0.0) );
   surfaceInfo.fGloss = 20.0;

    outSceneVertex.vColor = LightSurface( surfaceInfo, vCameraPos, vAlbedo, fShadow );

   // Hack lighting from other side
   vec3 vCameraDir = vCameraPos - surfaceInfo.vPos;
   vCameraDir = reflect( vCameraDir, surfaceInfo.vNormal );
   vec3 otherSideCameraPos = vCameraDir + surfaceInfo.vPos;
    outSceneVertex.vColor += LightSurface( surfaceInfo, otherSideCameraPos, vAlbedo, fShadow ) * 0.1;

    fAlpha *= 1.0 - abs( vUV.y * 2.0 - 1.0 );

   float NdotV = normalize(vCameraPos).y;
   fAlpha = mix( fAlpha, 1.0, exp2( abs(NdotV) * -5.0 ) );

   outSceneVertex.fAlpha = fAlpha;
}

void main()
{
   SceneVertex sceneVertex;

   vec2 vMouse = mouse;
   float orbitAngle = time * 0.4 + 2.5;

   float fov = 1.5;

   PlanetInfo planetInfo;

#if 1
  // planetInfo.vSurfaceColor0 = vec3(0.36, 0.16, 0.0001);
  // planetInfo.vSurfaceColor1 = vec3(1.0, 0.36, 0.000001);

   planetInfo.vOrigin = vec3(0.0);
   planetInfo.fRadius = 5.0;

   planetInfo.fSegments = 64.0;
   planetInfo.fSlices = 48.0;

#else
#endif

   float fOrbitDistance = (planetInfo.fRadius * 2.0) ;

   vec3 vCameraPos = vec3( sin(orbitAngle), 2. , cos(orbitAngle) ) * fOrbitDistance;
   vec3 vCameraTarget = vec3( 0.0, planetInfo.fRadius * 0.2, 0.0 );
   vec3 vCameraUp = vec3( 0.1, 1.0, 0.0 );

   if( false )
    {
      vCameraPos = vec3( 10.0, 8.0, 30.0 );
      vCameraTarget = vec3( 0.0, 0.0, 0.0 );
      vCameraUp = vec3( 0.0, 1.0, 0.0);
    }

   vec3 vCameraForwards = normalize(vCameraTarget - vCameraPos);

   mat3 mCamera;
    GetMatrixFromZY( vCameraForwards, normalize(vCameraUp), mCamera );

   float vertexIndex = vertexId;
 /*
   // Backdrop
   if ( vertexIndex >= 0.0 && vertexIndex < g_backdropVertexCount )
    {
     GenerateBackdropVertex( vertexIndex, vCameraPos, sceneVertex );
    }
*/
   vertexIndex -= g_backdropVertexCount;
/*
   // Stars
   if ( vertexIndex >= 0.0 && vertexIndex < g_starVertexCount )
    {
     GenerateStarVertex( vertexIndex, vCameraPos, sceneVertex );
    }
*/
   vertexIndex -= g_starVertexCount;

   // Planet
   float fPlanetVertexCount = GetPlanetVertexCount(planetInfo);
  // fPlanetVertexCount = 1. ;
  if ( vertexIndex >= 0.0 && vertexIndex < fPlanetVertexCount )
    {
     GeneratePlanetVertex( vertexIndex, vCameraPos, planetInfo, sceneVertex );
    }
   vertexIndex -= fPlanetVertexCount;
/*
   // Moon
   const int kMaxMoonCount = 5;
   float fMoonDist = planetInfo.fRadius * 6.0;
   for( int moonIndex=0; moonIndex < kMaxMoonCount; moonIndex++ )
    {
       if(moonIndex < planetInfo.iMoonCount)
        {
        PlanetInfo moonInfo;

        moonInfo.vSurfaceColor0 = vec3(0.7);
        moonInfo.vSurfaceColor1 = vec3(0.5);

        moonInfo.textureScale = 100.0;
        moonInfo.texturePersistence = 0.5;
        moonInfo.surfaceType = 0.9;

        moonInfo.vRingColor0 = vec3(1.0, 0.64, 0.09);
        moonInfo.vRingColor1 = vec3(0.36, 0.16, 0.0001);

        moonInfo.hasRings = false;

        float fAngle = hash11(fMoonDist) * 12.345 ;
        moonInfo.vOrigin = vec3(sin(fAngle), 0.0, cos(fAngle)) * fMoonDist;
        moonInfo.fRadius = planetInfo.fRadius * 0.025;
        fMoonDist = fMoonDist * 1.8;

        moonInfo.fSegments = 16.0;
        moonInfo.fSlices = 16.0;

        moonInfo.iMoonCount = 0;

        float fMoonVertexCount = GetPlanetVertexCount(moonInfo);
        if ( vertexIndex >= 0.0 && vertexIndex < fMoonVertexCount )
        {
        GeneratePlanetVertex( vertexIndex, vCameraPos, moonInfo, sceneVertex );
        }
        vertexIndex -= fMoonVertexCount;

        }
    }
  */

   // Ring
   if ( planetInfo.hasRings )
    {
      float fRingInner = 8.0;
      float fRingSize = 2.0;
      float fRingSeed = 0.0;
      for ( int ringIndex = 0; ringIndex < 6; ringIndex++ )
      {
        if ( vertexIndex >= 0.0 && vertexIndex < g_ringVertexCount )
        {
        GenerateRingVertex( vertexIndex, vCameraPos, planetInfo, sceneVertex, fRingInner, fRingInner + fRingSize, hash11(fRingInner) );
        }
        vertexIndex -= g_ringVertexCount;

        fRingInner += fRingSize;
        fRingInner += 0.02 + (sin( fRingSeed * 123.432 ) * 0.5 + 0.5) * 0.25;
        float fSizeRandom = sin( fRingSeed * 423.432 ) * 0.5 + 0.5;
        fRingSize = 0.1 + fSizeRandom * fSizeRandom * 2.0;
        fRingSeed += 1.0;
      }
    }

   if ( vertexIndex >= 0.0 )
    {
      sceneVertex.vWorldPos = vec3(0.0);
      sceneVertex.vColor = vec3(0.0);
      sceneVertex.fAlpha = 0.0;
    }

    // Fianl output position
 vec3 vViewPos = sceneVertex.vWorldPos;
    vViewPos -= vCameraPos;
   vViewPos = vViewPos * mCamera;

   vec2 vFov = vec2( 1.0, resolution.x / resolution.y ) * fov;
   vec2 vScreenPos = vViewPos.xy * vFov;

 gl_Position = vec4( vScreenPos.xy, -1.0, vViewPos.z );

   // Final output color
   vec3 vFinalColor = sceneVertex.vColor;

   vFinalColor = ApplyVignetting( (gl_Position.xy / gl_Position.w) * 0.5 + 0.5, vFinalColor );

   float VdotL = dot( vCameraForwards, -GetSunDir(vCameraPos) );

   // Adjust exposure if we are looking towards the sun
   float fExposure = (0.5 + VdotL * 0.5) * 5.0;

   fExposure /= GetSunIntensity( vCameraPos ) * 100000.0;

   fExposure += 0.5;

   fExposure *= min( 1.0, time / 5.0 );

   vFinalColor = PostProcess( vFinalColor, fExposure );

   v_color = vec4(vFinalColor * sceneVertex.fAlpha, sceneVertex.fAlpha);
}

