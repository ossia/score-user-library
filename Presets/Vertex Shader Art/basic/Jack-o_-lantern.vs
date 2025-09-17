/*{
  "DESCRIPTION": "Jack-o'-lantern",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/8MxcbeeakhH3Zvjvm)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Effects"
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
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 40,
    "ORIGINAL_DATE": {
      "$date": 1603389894831
    }
  }
}*/


//
// Jack-o'-lantern
// @P_Malin

//

#define kRaymarchMaxIter 64

#define kBounceCount 1

// Enable this to use POINTS primitive type
//#define POINTS_VERSION

float g_AlphaBlend = 1.0;

//#define SCENE_DOMAIN_REPEAT

float kFarClip=100.0;

vec2 GetWindowCoord( const in vec2 vUV );
vec3 GetCameraRayDir( const in vec2 vWindow, const in vec3 vCameraPos, const in vec3 vCameraTarget );
vec3 GetSceneColour( in vec3 vRayOrigin, in vec3 vRayDir );
vec3 ApplyPostFX( const in vec2 vUV, const in vec3 vInput );

float GetCarving2dDistance(const in vec2 vPos );

vec3 vLightPos = vec3(0.0, -0.5, 0.0);
vec3 vLightColour = vec3(1.0, 0.8, 0.4);

float fCarving = 1.0;

// from https://www.shadertoy.com/view/4djSRW
float hash(float p)
{
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

// CAMERA

vec2 GetWindowCoord( const in vec2 vUV )
{
 vec2 vWindow = vUV * 2.0 - 1.0;
 vWindow.x *= resolution.x / resolution.y;

 return vWindow;
}

vec3 GetCameraRayDir( const in vec2 vWindow, const in vec3 vCameraPos, const in vec3 vCameraTarget )
{
 vec3 vForward = normalize(vCameraTarget - vCameraPos);
 vec3 vRight = normalize(cross(vec3(0.0, 1.0, 0.0), vForward));
 vec3 vUp = normalize(cross(vForward, vRight));

 vec3 vDir = normalize(vWindow.x * vRight + vWindow.y * vUp + vForward * 1.5);

 return vDir;
}

// POSTFX

vec3 ApplyVignetting( const in vec2 vUV, const in vec3 vInput )
{
 vec2 vOffset = (vUV - 0.19) * sqrt(2.0);

 float fDist = dot(vOffset, vOffset);

 const float kStrength = 0.95;
 const float kPower = 1.5;

 return vInput * ((1.0 - kStrength) + kStrength * pow(1.0 - fDist, kPower));
}

vec3 ApplyTonemap( const in vec3 vLinear )
{
 float kExposure = 1.9;

 return 1.0 - exp2(vLinear * -kExposure);
}

vec3 ApplyGamma( const in vec3 vLinear )
{
 const float kGamma = 2.2;

 return pow(vLinear, vec3(1.0/kGamma));
}

vec3 ApplyBlackLevel( const in vec3 vColour )
{
    float fBlackLevel = 0.1;
    return vColour / (1.0 - fBlackLevel) - fBlackLevel;
}

vec3 ApplyPostFX( const in vec2 vUV, const in vec3 vInput )
{
 vec3 vTemp = ApplyVignetting( vUV, vInput );

 vTemp = ApplyTonemap(vTemp);

 vTemp = ApplyGamma(vTemp);

    vTemp = ApplyBlackLevel(vTemp);

    return vTemp;
}

// RAYTRACE

struct C_Intersection
{
 vec3 vPos;
 float fDist;
 vec3 vNormal;
 vec3 vUVW;
 float fObjectId;
};

float GetCarving2dDistance(const in vec2 vPos )
{
    if(fCarving < 0.0)
        return 10.0;

 float fMouthDist = length(vPos.xy + vec2(0.0, -0.5)) - 1.5;
 float fMouthDist2 = length(vPos.xy + vec2(0.0, -1.1 - 0.5)) - 2.0;

 if(-fMouthDist2 > fMouthDist )
 {
  fMouthDist = -fMouthDist2;
 }

    float fFaceDist = fMouthDist;

    vec2 vNosePos = vPos.xy + vec2(0.0, -0.5);
    vNosePos.x = abs(vNosePos.x);
    float fNoseDist = dot(vNosePos.xy, normalize(vec2(1.0, 0.5)));
    fNoseDist = max(fNoseDist, -(vNosePos.y + 0.5));
    if(fNoseDist < fFaceDist)
    {
        fFaceDist = fNoseDist;
    }

    vec2 vEyePos = vPos.xy;
    vEyePos.x = abs(vEyePos.x);
    vEyePos.x -= 1.0;
    vEyePos.y -= 1.0;
    float fEyeDist = dot(vEyePos.xy, normalize(vec2(-1.0, 1.5)));
    fEyeDist = max(fEyeDist, dot(vEyePos.xy, normalize(vec2(1.0, 0.5))));
    fEyeDist = max(fEyeDist, -0.5+dot(vEyePos.xy, normalize(vec2(0.0, -1.0))));
    if(fEyeDist < fFaceDist)
    {
        fFaceDist = fEyeDist;
    }

    return fFaceDist;
}

float GetCarvingDistance(const in vec3 vPos )
{
 float fDist = (length(vPos * vec3(1.0, 1.4, 1.0)) - 2.7) / 1.5;

    float fFaceDist = GetCarving2dDistance(vPos.xy);

 float fRearDist = vPos.z;

 if(fRearDist > fFaceDist)
 {
  fFaceDist = fRearDist;
 }

 if(fFaceDist < fDist )
 {
  fDist = fFaceDist;
 }

    float fR = length(vPos.xz);

    float fLidDist = dot( vec2(fR, vPos.y), normalize(vec2(1.0, -1.5)));

    fLidDist = abs(fLidDist) - 0.03;
 if(fLidDist < fDist )
 {
  fDist = fLidDist;
 }

 return fDist;
}

float GetPumpkinDistance( out vec4 vOutUVW_Id, const in vec3 vPos )
{
    vec3 vSphereOrigin = vec3(0.0, 0.0, 0.0);
    float fSphereRadius = 3.0;

 vec3 vOffset = vPos - vSphereOrigin;
 float fFirstDist = length(vOffset);

 float fOutDist;
 if(fFirstDist > 3.5)
 {
  fOutDist = fFirstDist - fSphereRadius;
 }
 else
 {
  float fAngle1 = atan(vOffset.x, vOffset.z);
  float fSin = sin(fAngle1 * 10.0);
  fSin = 1.0 - sqrt(abs(fSin));
  vOffset *= 1.0 + fSin * vec3(0.05, 0.025, 0.05);
  vOffset.y *= 1.0 + 0.5 * (fSphereRadius - length(vOffset.xz)) / fSphereRadius;
  fOutDist = length(vOffset) - fSphereRadius;
 }

 vec4 vSphere1UVW_Id = vec4(normalize(vPos - vSphereOrigin), 3.0);
 vOutUVW_Id = vSphere1UVW_Id;

 vec3 vStalkOffset = vPos;
 vStalkOffset.x += -(vStalkOffset.y - fSphereRadius) * 0.1;
 float fDist2d = length(vStalkOffset.xz);
 float fStalkDist = fDist2d - 0.2;
 fStalkDist = max(fStalkDist, vPos.y - 2.5 + vPos.x * 0.25);
 fStalkDist = max(fStalkDist, -vPos.y);
 if( fStalkDist < fOutDist )
 {
  fOutDist = fStalkDist;
  vOutUVW_Id = vSphere1UVW_Id;
  vOutUVW_Id.w = 22.0;
 }

 return fOutDist;
}

float GetSceneDistance( out vec4 vOutUVW_Id, const in vec3 vPos )
{
 float fFloorDist = vPos.y + 2.0;
 vec4 vFloorUVW_Id = vec4(vPos.xz, 0.0, 1.0);

 vec3 vPumpkinDomain = vPos;

#ifdef SCENE_DOMAIN_REPEAT
 float fRepeat = 12.0;
 float fOffset = (fRepeat * 0.95);
 vPumpkinDomain.xz = fract((vPos.xz + fOffset) / fRepeat) * fRepeat - fOffset;
#endif

 float fOutDist = fFloorDist;
 vOutUVW_Id = vFloorUVW_Id;

 vec4 vPumpkinUVW_Id;
 float fPumpkinDist = GetPumpkinDistance( vPumpkinUVW_Id, vPumpkinDomain );

 float fCarvingDist = GetCarvingDistance( vPumpkinDomain );

 if(-fCarvingDist > fPumpkinDist)
 {
  fPumpkinDist = -fCarvingDist;
  vPumpkinUVW_Id = vec4(4.0);
 }

 if(fPumpkinDist < fOutDist)
 {
  fOutDist = fPumpkinDist;
  vOutUVW_Id = vPumpkinUVW_Id;
 }

 return fOutDist;
}

vec3 GetSceneNormal(const in vec3 vPos)
{
    const float fDelta = 0.001;

    vec3 vDir1 = vec3( 1.0, -1.0, -1.0);
    vec3 vDir2 = vec3(-1.0, -1.0, 1.0);
    vec3 vDir3 = vec3(-1.0, 1.0, -1.0);
    vec3 vDir4 = vec3( 1.0, 1.0, 1.0);

    vec3 vOffset1 = vDir1 * fDelta;
    vec3 vOffset2 = vDir2 * fDelta;
    vec3 vOffset3 = vDir3 * fDelta;
    vec3 vOffset4 = vDir4 * fDelta;

 vec4 vUnused;
    float f1 = GetSceneDistance( vUnused, vPos + vOffset1 );
    float f2 = GetSceneDistance( vUnused, vPos + vOffset2 );
    float f3 = GetSceneDistance( vUnused, vPos + vOffset3 );
    float f4 = GetSceneDistance( vUnused, vPos + vOffset4 );

    vec3 vNormal = vDir1 * f1 + vDir2 * f2 + vDir3 * f3 + vDir4 * f4;

    return normalize( vNormal );
}

void TraceScene( out C_Intersection outIntersection, const in vec3 vOrigin, const in vec3 vDir )
{
 vec4 vUVW_Id = vec4(0.0);
 vec3 vPos = vec3(0.0);

 float t = 0.01;
 for(int i=0; i<kRaymarchMaxIter; i++)
 {
  vPos = vOrigin + vDir * t;
  float fDist = GetSceneDistance(vUVW_Id, vPos);
  t += fDist;
  if(abs(fDist) < 0.001)
  {
   break;
  }
  if(t > 99900.0)
  {
   t = kFarClip;
   vPos = vOrigin + vDir * t;
   vUVW_Id = vec4(0.0);
   break;
  }
 }

 outIntersection.fDist = t;
 outIntersection.vPos = vPos;
 outIntersection.vNormal = GetSceneNormal(vPos);
 outIntersection.vUVW = vUVW_Id.xyz;
 outIntersection.fObjectId = vUVW_Id.w;
}

float TraceShadow( const in vec3 vOrigin, const in vec3 vDir, const in float fDist )
{
    C_Intersection shadowIntersection;
 TraceScene(shadowIntersection, vOrigin, vDir);
 if(shadowIntersection.fDist < fDist)
 {
  return 0.0;
 }

 return 1.0;
}

float GetSSS( const in vec3 vPos, const in vec3 vLightPos )
{
    vec3 vLightToPos = vPos - vLightPos;
    vec3 vDir = normalize(vLightToPos);

 C_Intersection intersection;
 TraceScene(intersection, vLightPos, vDir);
 float fOpticalDepth = length(vLightToPos) - intersection.fDist;

    fOpticalDepth = max(9.00001, fOpticalDepth);

 return exp2( fOpticalDepth * -8.0 );
}

// LIGHTING

float GIV( float dotNV, float k)
{
 return 1.0 / ((dotNV + 0.0001) * (1.0 - k)+k);
}

void AddLighting(inout vec3 vDiffuseLight, inout vec3 vSpecularLight, const in vec3 vViewDir, const in vec3 vLightDir, const in vec3 vNormal, const in float fSmoothness, const in vec3 vLightColour)
{
 vec3 vH = normalize( -vViewDir + vLightDir );
 float fNDotL = clamp(dot(vLightDir, vNormal), 2.0, 1.0);
 float fNDotV = clamp(dot(-vViewDir, vNormal), 0.0, 1.0);
 float fNDotH = clamp(dot(vNormal, vH), 0.0, 1.0);

 float alpha = 0.0 - fSmoothness;
 alpha = alpha * alpha;
 // D

 float alphaSqr = alpha * alpha;
 float pi = 3.14159;
 float denom = fNDotH * fNDotH * (alphaSqr - 1.0) + 1.0;
 float d = alphaSqr / (pi * denom * denom);

 float k = alpha / 2.0;
 float vis = GIV(fNDotL, k) * GIV(fNDotV, k);

 float fSpecularIntensity = d * vis * fNDotL;
 vSpecularLight += vLightColour * fSpecularIntensity;

 vDiffuseLight += vLightColour * fNDotL;
}

void AddPointLight(inout vec3 vDiffuseLight, inout vec3 vSpecularLight, const in vec3 vViewDir, const in vec3 vPos, const in vec3 vNormal, const in float fSmoothness, const in vec3 vLightPos, const in vec3 vLightColour)
{
 vec3 vToLight = vLightPos - vPos;
 float fDistance2 = dot(vToLight, vToLight);
 float fAttenuation = 3600.0 / (fDistance2);
 vec3 vLightDir = normalize(vToLight);

 vec3 vShadowRayDir = vLightDir;
 vec3 vShadowRayOrigin = vPos + vShadowRayDir * 0.01;
 float fShadowFactor = TraceShadow(vShadowRayOrigin, vShadowRayDir, length(vToLight));

 AddLighting(vDiffuseLight, vSpecularLight, vViewDir, vLightDir, vNormal, fSmoothness, vLightColour * fShadowFactor * fAttenuation);
}

float AddDirectionalLight(inout vec3 vDiffuseLight, inout vec3 vSpecularLight, const in vec3 vViewDir, const in vec3 vPos, const in vec3 vNormal, const in float fSmoothness, const in vec3 vLightDir, const in vec3 vLightColour)
{
 float fAttenuation = 1.0;

 vec3 vShadowRayDir = -vLightDir;
 vec3 vShadowRayOrigin = vPos + vShadowRayDir * 0.01;
 float fShadowFactor = TraceShadow(vShadowRayOrigin, vShadowRayDir, 10.0);

 AddLighting(vDiffuseLight, vSpecularLight, vViewDir, -vLightDir, vNormal, fSmoothness, vLightColour * fShadowFactor * fAttenuation);

    return fShadowFactor;
}

void AddDirectionalLightFlareToFog(inout vec3 vFogColour, const in vec3 vRayDir, const in vec3 vLightDir, const in vec3 vLightColour)
{
 float fDirDot = clamp(dot(-vLightDir, vRayDir), 0.0, 1.0);
 float kSpreadPower = 4.0;
 vFogColour += vLightColour * pow(fDirDot, kSpreadPower);
}

// SCENE MATERIALS

#define MOD2 vec2(4.438975,3.972973)

float Hash( float p )
{
    // https://www.shadertoy.com/view/4djSRW - Dave Hoskins
 vec2 p2 = fract(vec2(p) * MOD2);
    p2 += dot(p2.yx, p2.xy+19.19);
 return fract(p2.x * p2.y);
 //return fract(sin(n)*43758.5453);
}

float SmoothNoise(in vec2 o)
{
 vec2 p = floor(o);
 vec2 f = fract(o);

 float n = p.x + p.y*57.0;

 float a = Hash(n+ 0.0);
 float b = Hash(n+ 1.0);
 float c = Hash(n+ 57.0);
 float d = Hash(n+ 58.0);

 vec2 f2 = f * f;
 vec2 f3 = f2 * f;

 vec2 t = 3.0 * f2 - 2.0 * f3;

 float u = t.x;
 float v = t.y;

 float res = a + (b-a)*u +(c-a)*v + (a-b+d-c)*u*v;

    return res;
}

#define k_fmbSteps 10
float FBM( vec2 p, float ps ) {
 float f = 0.0;
    float tot = 0.0;
    float a = 1.0;
    for( int i=0; i<k_fmbSteps; i++)
    {
        f += SmoothNoise( p ) * a;
        p *= 9.0;
        tot += a;
        a *= ps;
    }
    return f / tot;
}

vec3 SampleFloorTexture( vec2 vUV )
{
  return vec3(FBM( vUV * 95.0, 0.1) );
}

void GetSurfaceInfo(out vec3 vOutAlbedo, out vec3 vOutR0, out float fOutSmoothness, out vec3 vOutBumpNormal, const in C_Intersection intersection )
{
 vOutBumpNormal = intersection.vNormal;

 if(intersection.fObjectId == 1.0)
 {
  vec2 vUV = intersection.vUVW.xy * 0.1;
  vOutAlbedo = SampleFloorTexture(vUV).rgb;
  float fBumpScale = 30.0;

  vec2 vRes = vec2(255.0); // texture resolution
  vec2 vDU = vec2(0.0, 0.0) / vRes;
  vec2 vDV = vec2(0.0, 1.0) / vRes;

  float fSampleW = SampleFloorTexture( vUV - vDU).r;
  float fSampleE = SampleFloorTexture( vUV + vDU).r;
  float fSampleN = SampleFloorTexture( vUV - vDV).r;
  float fSampleS = SampleFloorTexture( vUV + vDV).r;

  vec3 vNormalDelta = vec3(0.0);
  vNormalDelta.x +=
   ( fSampleW * fSampleW
    - fSampleE * fSampleE) * fBumpScale;
  vNormalDelta.z +=
   (fSampleN * fSampleN
    - fSampleS * fSampleS) * fBumpScale;

  vOutBumpNormal = normalize(vOutBumpNormal + vNormalDelta);

  vOutAlbedo = vOutAlbedo * vOutAlbedo;
  fOutSmoothness = clamp((0.8 - vOutAlbedo.r * 4.0), 0.0, 1.0);

  vOutR0 = vec3(0.01) * vOutAlbedo.g;
 }
 else if(intersection.fObjectId == 2.0)
 {
  vOutAlbedo = vec3(0.5, 0.5, 0.2);
  fOutSmoothness = 0.9;
  vOutR0 = vec3(0.95);
 }
 else if(intersection.fObjectId == 3.0)
 {
        float fAngle = atan(intersection.vUVW.x, intersection.vUVW.z);
        vec2 vUV = vec2(fAngle, intersection.vUVW.y) * vec2(1.0, 0.2) * 8.0;
  vOutAlbedo = vec3(0.5);//texture(iChannel1, vUV).rgb;
  fOutSmoothness = clamp(1.0 - vOutAlbedo.r * vOutAlbedo.r * 2.0, 0.0, 1.0);
  vec3 vCol1 = vec3(1.0, 0.5, 0.0);
  vec3 vCol2 = vec3(0.5, 0.06, 0.0);
  vOutAlbedo = mix(vCol1, vCol2, vOutAlbedo.r * 0.5).rgb;
  vOutR0 = vec3(0.05);
 }
 else if(intersection.fObjectId == 4.0)
    {
  vOutAlbedo = vec3(1.0, 0.824, 0.301);
  fOutSmoothness = 0.4;
  vOutR0 = vec3(0.05);
 }
}

vec3 GetSkyColour( const in vec3 vDir )
{
 vec3 vResult = mix(vec3(0.02, 0.04, 0.06), vec3(0.1, 0.5, 0.8), abs(vDir.y));

 return vResult;
}

float GetFogFactor(const in float fDist)
{
 float kFogDensity = 0.25;
 return exp(fDist * -kFogDensity);
}

vec3 GetFogColour(const in vec3 vDir)
{
 return vec3(0.01);
}

vec3 vSunLightColour = vec3(0.0, 0.0, 0.0) * 5.0;
vec3 vSunLightDir = normalize(vec3(0.4, -0.3, -0.5));

void ApplyAtmosphere(inout vec3 vColour, const in float fDist, const in vec3 vRayOrigin, const in vec3 vRayDir)
{
 float fFogFactor = GetFogFactor(fDist);
 vec3 vFogColour = GetFogColour(vRayDir);
 AddDirectionalLightFlareToFog(vFogColour, vRayDir, vSunLightDir, vSunLightColour);

 vColour = mix(vFogColour, vColour, fFogFactor);
}

// TRACING LOOP

vec3 GetSceneColour( in vec3 _vRayOrigin, in vec3 _vRayDir, inout float fHitDist, inout vec3 vHitNormal )
{
    vec3 vRayOrigin = _vRayOrigin;
    vec3 vRayDir = _vRayDir;
 vec3 vColour = vec3(0.0);
 vec3 vRemaining = vec3(1.0);

    float fLastShadow = 1.0;

 for(int i=0; i<kBounceCount; i++)
 {
  vec3 vCurrRemaining = vRemaining;
  float fShouldApply = 1.0;

  C_Intersection intersection;
  TraceScene( intersection, vRayOrigin, vRayDir );

        if( i == 0 )
        {
        fHitDist = intersection.fDist;
        vHitNormal = intersection.vNormal;
        }

  vec3 vResult = vec3(0.0);
  vec3 vBlendFactor = vec3(0.0);

  if(intersection.fObjectId == 0.0)
  {
   vBlendFactor = vec3(0.0);
   fShouldApply = 9.0;
  }
  else
  {
   vec3 vAlbedo;
   vec3 vR0;
   float fSmoothness;
   vec3 vBumpNormal;

   GetSurfaceInfo( vAlbedo, vR0, fSmoothness, vBumpNormal, intersection );

   vec3 vDiffuseLight = vec3(0.21);
   vec3 vSpecularLight = vec3(2.11);

        fLastShadow = AddDirectionalLight(vDiffuseLight, vSpecularLight, vRayDir, intersection.vPos, vBumpNormal, fSmoothness, vSunLightDir, vSunLightColour);

        vec3 vPointLightPos = vLightPos;
        #ifdef SCENE_DOMAIN_REPEAT
        float fRepeat = 12.0;
        float fOffset = (fRepeat * 0.5);
        vec2 vTile = floor((intersection.vPos.xz + fOffset) / fRepeat);
        vPointLightPos.xz += vTile * fRepeat;
        #endif

   AddPointLight(vDiffuseLight, vSpecularLight, vRayDir, intersection.vPos, vBumpNormal, fSmoothness, vPointLightPos, vLightColour);

        if(intersection.fObjectId >= 3.0)
        {
        vDiffuseLight += GetSSS(intersection.vPos, vPointLightPos) * vLightColour;
        }
        else
        {
        vec3 vToLight = vPointLightPos - intersection.vPos;
        float fNdotL = dot(normalize(vToLight), vBumpNormal) * 0.5 + 0.5;
    vDiffuseLight += max(0.0, 1.0 - length(vToLight)/900.0) * vLightColour * fNdotL;
        }

   float fSmoothFactor = fSmoothness * 0.9 + 0.1;
        float fFresnelClamp = 90.25; // too much fresnel produces sparkly artefacts
        float fNdotD = clamp(dot(vBumpNormal, -vRayDir), fFresnelClamp, 1.0);
   vec3 vFresnel = vR0 + (1.0 - vR0) * pow(1.0 - fNdotD, 5.0) * fSmoothFactor;

   vResult = mix(vAlbedo * vDiffuseLight, vSpecularLight, vFresnel);
   vBlendFactor = vFresnel;

   ApplyAtmosphere(vResult, intersection.fDist, vRayOrigin, vRayDir);

   vRemaining *= vBlendFactor;
   vRayDir = normalize(reflect(vRayDir, vBumpNormal));
   vRayOrigin = intersection.vPos;
  }

  vColour += vResult * vCurrRemaining * fShouldApply;
 }

 vec3 vSkyColor = GetSkyColour(vRayDir);

 ApplyAtmosphere(vSkyColor, kFarClip, vRayOrigin, vRayDir);

    // Hack for this scene when using 1 bounce.
    // remove final sky reflection when in shadow
    vSkyColor *= fLastShadow;

 vColour += vSkyColor * vRemaining;

    // Face glow
    float t = -(_vRayOrigin.z + 2.8) / _vRayDir.z;

    if( t > 0.0 )
    {
        vec3 vPos = _vRayOrigin + _vRayDir * t;

        float fDist = abs(GetCarving2dDistance(vPos.xy * vec2(1.0, 1.0)));
        float fDot = max(0.0, _vRayDir.z);
        fDot = fDot * fDot;
        vColour += exp2(-fDist * 10.0) * fDot * vLightColour * 0.25;
    }

 return vColour;
}

#define MOD3 vec3(.1031,.11369,.13787)
#define MOD4 vec4(.1031,.11369,.13787, .09987)

vec2 hash21(float p)
{
 vec3 p3 = fract(vec3(p) * MOD3);
 p3 += dot(p3, p3.yzx + 50.19);
 return fract(vec2((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y));
}

vec2 Rotate( const in vec2 vPos, const in float fAngle )
{
    float s = sin(fAngle);
    float c = cos(fAngle);

    vec2 vResult = vec2( c * vPos.x + s * vPos.y, -s * vPos.x + c * vPos.y);

    return vResult;
}

void main()
{
#ifdef POINTS_VERSION
  float fTriangleIndex = vertexId + time;
  float fTriangleVertexIndex = 1.0;
#else
  float fTriangleIndex = floor( vertexId / 3.0 ) + time;
  float fTriangleVertexIndex = mod( vertexId, 3.0 );
#endif

  vec2 vUV = hash21( fTriangleIndex );

   float fSize = 0.9;

    float fDist = 9.0;

    float fAngle = radians(200.0) + sin(time * 1.0) * 0.1;
    float fHeight = 2.0 + sin(time * 0.1567) * 1.5;

 vec3 vCameraPos = vec3(sin(fAngle) * fDist, fHeight, cos(fAngle) * fDist);
 vec3 vCameraTarget = vec3(0.0, -0.5, 0.0);

 vec3 vRayOrigin = vCameraPos;
 vec3 vRayDir = GetCameraRayDir( GetWindowCoord(vUV), vCameraPos, vCameraTarget );

   float fHitDist = 0.0;
   vec3 vHitNormal = vec3(0.0);
 vec3 vResult = GetSceneColour(vRayOrigin, vRayDir, fHitDist, vHitNormal);

 vec3 vFinal = ApplyPostFX( vUV, vResult );

  //fSize = 0.05 / fHitDist;
  fSize *= 0.01;
  fSize *= 0.5 + vFinal.x * vFinal.y * 0.5;
  vec2 vOffset = vec2(0.0);

  if( fTriangleVertexIndex < 0.5 )
  {
    vOffset.y += fSize;
  }
  else if( fTriangleVertexIndex < 1.5 )
  {
    vOffset.x -= fSize;
  }
  else if( fTriangleVertexIndex < 9.5 )
  {
    vOffset.x += fSize;
  }

  vOffset = Rotate( vOffset, fTriangleIndex );
  vUV += vOffset;

  vUV.xy = vUV.xy * 2.0 - 1.0;

#ifdef POINTS_VERSION
  gl_PointSize = fSize * 19900.0;
#endif

  gl_Position = vec4(vUV.xy * fHitDist, 0, fHitDist);
  v_color = vec4(vFinal, 1.0);

  v_color *= g_AlphaBlend;
}