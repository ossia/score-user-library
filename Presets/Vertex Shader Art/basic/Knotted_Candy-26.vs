/*{
  "DESCRIPTION": "Knotted Candy",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/zBGJ6RhGK6EAJvuHL)",
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
    0.10196078431372549,
    0.19607843137254902,
    0.25098039215686274,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 60,
    "ORIGINAL_DATE": {
      "$date": 1446223211701
    }
  }
}*/

// Knotted Candy - @P_Malin

// Some different shapes...

#define SHAPE_TWO_BRAIDS
//#define SHAPE_THREE_BRAIDS
//#define SHAPE_TORUS
//#define SHAPE_MOBIUS

//#define RIBBON

#ifdef SHAPE_TWO_BRAIDS
  float twist = 3.0;
  float radius1 = 0.25;
  float radius2 = 3.0;
  float radius3 = 0.4;

  float waves = 4.0;
  float braids = 2.0;

  vec2 vShapeDim = vec2( 32.0, 256.0 );
#elif defined(SHAPE_THREE_BRAIDS)
  float twist = 5.0;
  float radius1 = 0.15;
  float radius2 = 3.0;
  float radius3 = 0.5;

  float waves = 4.0;
  float braids = 3.0;

  vec2 vShapeDim = vec2( 24.0, 192.0 );
#elif defined(SHAPE_TORUS)
  // Torus
  float twist = 0.0;
  float radius1 = 1.0;
  float radius2 = 3.0;
  float radius3 = 0.0;

  float waves = 3.0;
  float braids = 2.0;

  vec2 vShapeDim = vec2( 32.0, 256.0 );
#elif defined(SHAPE_MOBIUS)
  // Torus
  float twist = 2.0;
  float radius1 = 1.0;
  float radius2 = 2.0;
  float radius3 = 0.0;

  float waves = 0.0;
  float braids = 2.0;

  #define RIBBON
  vec2 vShapeDim = vec2( 32.0, 256.0 );
#else
#error INVALID SHAPE DEFINE
#endif

// Inputs:
// vertexId
// time
// resolution

// Outputs:
// gl_Position
// v_color

#define PI radians( 180.0 )

void GetQuadInfo( const float vertexIndex, out float x, out float y, out float quadId )
{
  float twoTriVertexIndex = mod( vertexIndex, 6.0 );
  float triVertexIndex = mod( vertexIndex, 3.0 );
  float quadVertexIndex = triVertexIndex;
  if ( twoTriVertexIndex >= 3.0 )
  {
    quadVertexIndex ++;
  }

  if ( quadVertexIndex < 0.5 )
  {
    x = 0.0;
    y = 0.0;
  }
  else if ( quadVertexIndex < 1.5 )
  {
    x = 1.0;
    y = 0.0;
  }
  else if ( quadVertexIndex < 2.5 )
  {
    x = 0.0;
    y = 1.0;
  }
  else if ( quadVertexIndex < 3.5 )
  {
    x = 1.0;
    y = 1.0;
  }

  quadId = floor( vertexIndex / 6.0 );
}

vec2 Rotate( const in vec2 vPos, const in float fAngle )
{
    float s = sin(fAngle);
    float c = cos(fAngle);

    vec2 vResult = vec2( c * vPos.x + s * vPos.y, -s * vPos.x + c * vPos.y);

    return vResult;
}

struct SurfaceInfo
{
 vec3 vPos;
   vec3 vNormal;
};

void Translate( vec3 vTranslation, inout vec3 vPos )
{
 vPos += vTranslation;
}

void RotateX( float theta, inout vec3 vPos )
{
   vPos.yz = Rotate( vPos.yz, theta );
}

void RotateY( float theta, inout vec3 vPos )
{
   vPos.xz = Rotate( vPos.xz, theta );
}

void RotateZ( float theta, inout vec3 vPos )
{
   vPos.xy = Rotate( vPos.xy, theta );
}

void AddPointLight( vec3 vLightPos, vec3 vLightColor, const SurfaceInfo surfaceInfo, inout vec3 vDiffuse, inout vec3 vSpecular )
{
  vec3 vLightDir = normalize(vLightPos - surfaceInfo.vPos);
  vec3 vViewDir = normalize(-surfaceInfo.vPos);

  float NdotL = max( 0.0, dot( vLightDir, surfaceInfo.vNormal ) );

  vec3 vHalfAngle = normalize( vViewDir + vLightDir );

  float NdotH = max( 0.0, dot( vHalfAngle, surfaceInfo.vNormal ) );

  vDiffuse += NdotL * vLightColor;

  float fPower = 80.0;
  vSpecular += pow( NdotH, fPower ) * (fPower * 8.0 * PI) * NdotL * vLightColor;
}

void AddDirectionalLight( vec3 vLightDir, vec3 vLightColor, const SurfaceInfo surfaceInfo, inout vec3 vDiffuse, inout vec3 vSpecular )
{
  vec3 vViewDir = normalize(-surfaceInfo.vPos);

  float NdotL = max( 0.0, dot( vLightDir, surfaceInfo.vNormal ) );

  vec3 vHalfAngle = normalize( vViewDir + vLightDir );

  float NdotH = max( 0.0, dot( vHalfAngle, surfaceInfo.vNormal ) );

  vDiffuse += NdotL * vLightColor;

  float fPower = 80.0;
  vSpecular += pow( NdotH, fPower ) * (fPower * 8.0 * PI) * NdotL * vLightColor;
}

vec3 GetSkyColor( vec3 vDir )
{
  return mix( vec3(0.01, 0.1, 0.4), vec3(0.2, 0.5, 0.6) * 5.0, vDir.y * 0.5 + 0.5 );
}

vec3 LightSurface( const SurfaceInfo surfaceInfo, const vec3 vAlbedo )
{
  vec3 vDiffuseLight = vec3(0.0);
  vec3 vSpecLight = vec3(0.0);

  // use background color
  vec3 vAmbient = GetSkyColor( surfaceInfo.vNormal );
  vDiffuseLight += vAmbient;
  vSpecLight += vAmbient;

  AddPointLight( vec3(3.0, 2.0, 30.0), vec3( 0.5, 1.0, 1.0), surfaceInfo, vDiffuseLight, vSpecLight );
  AddDirectionalLight( normalize(vec3(0.0, 1.0, 0.0)), vec3( 3.0, 2.9, 1.5), surfaceInfo, vDiffuseLight, vSpecLight );

  //AddDirectionalLight( normalize(vec3(0.0, -1.0, 0.0)), vAmbient * 0.1, surfaceInfo, vDiffuseLight, vSpecLight );

  // viewer is at origin
  vec3 vViewDir = normalize(-surfaceInfo.vPos);

  float fNdotD = clamp(dot(surfaceInfo.vNormal, vViewDir), 0.0, 1.0);
  vec3 vR0 = vec3(0.04);
  vec3 vFresnel = vR0 + (1.0 - vR0) * pow(1.0 - fNdotD, 5.0);

  vec3 vColor = mix( vDiffuseLight * vAlbedo, vSpecLight, vFresnel );

  return vColor;
}

vec3 PostProcess( vec3 vColor )
{
  float kExposure = 1.0;
  vColor = vec3(1.0) - exp2( vColor * -kExposure );

  vColor = pow( vColor, vec3(1.0 / 2.2) );

  return vColor;
}

vec3 ApplyVignetting( const in vec2 vUV, const in vec3 vInput )
{
 vec2 vOffset = (vUV - 0.5) * sqrt(2.0);

 float fDist = dot(vOffset, vOffset);

 const float kStrength = 0.95;
 const float kPower = 1.5;

 return vInput * ((1.0 - kStrength) + kStrength * pow(1.0 - fDist, kPower));
}

void ProcessBackdrop( float vertexIndex )
{
  float quadX, quadY, quadId;

  GetQuadInfo( vertexId, quadX, quadY, quadId );

  vec2 vDim = vec2( 8.0, 8.0 );

  vec2 vUV;

  vec2 quadTile;
  quadTile.x = mod(quadId, vDim.x);
  quadTile.y = floor(quadId / vDim.x);

  vUV.x = quadX + quadTile.x;
  vUV.y = quadY + quadTile.y;

  vUV = vUV * (1.0 / vDim);

  gl_Position = vec4( vUV.xy * 2.0 - 1.0, 0.0, 1.0 );

  vec3 vPos = vec3( vUV.xy * 2.0 - 1.0, 2.0 );
  vPos.y *= resolution.x / resolution.y;

  vec3 vColor = GetSkyColor( normalize( vPos ) );

  vColor = ApplyVignetting( vUV.xy, vColor );

  vColor = PostProcess( vColor );

  v_color = vec4( vColor, 1.0 );
}

void TransformPoint( inout vec3 vPos, vec2 vUV, float t )
{
  vPos += vec3(0.0, radius1, 0.0);
  RotateZ( vUV.x * PI * 2.0 + vUV.y * PI * 2.0 * twist, vPos );

#ifdef RIBBON
  vPos.y *= 0.1;
#endif

  vPos += vec3(-radius3, 0.0, 0.0);
  RotateZ( vUV.y * PI * 2.0 * (waves + 1.0 / braids), vPos );

  vPos += vec3(-radius2, 0.0, 0.0);

  RotateY( vUV.y * PI * 2.0, vPos );

  // animated spin
  RotateY( t * 0.5, vPos );
  RotateX( t, vPos );

  vPos += vec3(0.0, 0.0, 30.0);
}

void ProcessShape( float vertexIndex )
{
  float quadX, quadY, quadId;

  GetQuadInfo( vertexId, quadX, quadY, quadId );

  vec2 vUV;

  vec2 quadTile;
  quadTile.x = mod(quadId, vShapeDim.x);
  quadTile.y = floor(quadId / vShapeDim.x);

  vUV.x = quadX + quadTile.x;
  vUV.y = quadY + quadTile.y;

  vUV = vUV * (1.0 / vShapeDim);

  vec3 vPos = vec3(0.0, 0.0, 0.0);
  TransformPoint( vPos, vUV, time );

  // Lazy normal calculation

  float fDelta = 0.0021;
  vec3 vPosdU = vec3(0.0, 0.0, 0.0);
  TransformPoint( vPosdU, vUV + vec2(fDelta, 0.0), time );
  vec3 vPosdV = vec3(0.0, 0.0, 0.0);
  TransformPoint( vPosdV, vUV + vec2(0.0, fDelta), time );

  SurfaceInfo surfaceInfo;
  surfaceInfo.vPos = vPos;
  surfaceInfo.vNormal = normalize(cross(vPosdV - vPos, vPosdU - vPos));

  vec3 vViewPos = surfaceInfo.vPos;
  vec2 vFov = vec2( 1.0, resolution.x / resolution.y ) * 4.0;
  vec2 vScreenPos = vViewPos.xy * vFov;

  gl_Position = vec4( vScreenPos.xy, (1.0 / -vViewPos.z), vViewPos.z );

  float stripes = 4.0;
  vec3 vAlbedo = vec3(1.0);

  float fTile = step( 0.5, fract( (quadTile.x * stripes / vShapeDim.x) ));
  vAlbedo = mix( vec3(1.0, 0.01, 0.01), vec3(0.8, 0.8, 0.8), fTile );

  vec3 vColor = LightSurface( surfaceInfo, vAlbedo );

  vColor = ApplyVignetting( (vScreenPos.xy / vViewPos.z) * 0.5 + 0.5, vColor );

  vColor = PostProcess( vColor );

  v_color = vec4(vColor, 1.0);
}

void main()
{
 if( vertexId < 64.0 * 6.0 )
    {
  ProcessBackdrop(vertexId);
    }
  else
  {
  ProcessShape(vertexId - 64.0 * 6.0);
  }

}
