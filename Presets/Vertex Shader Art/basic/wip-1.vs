/*{
  "DESCRIPTION": "wip",
  "CREDIT": "johan (ported from https://www.vertexshaderart.com/art/GY6bT7gTsHXRvMshg)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 56549,
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
    "ORIGINAL_VIEWS": 86,
    "ORIGINAL_DATE": {
      "$date": 1446229802719
    }
  }
}*/

#define PI 3.14159
#define NUM_SEGMENTS 21.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define OCTAVES 8

const float DIM_X = 128.;
const float DIM_Y = 64.;

const float BG_DIM_X = 8.;
const float BG_DIM_Y = 6.;
//#define FIT_VERTICAL

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 hash(vec3 p){
  return vec3(0.);
}

float rand(in vec2 co){
   return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float rand2(in vec2 co){
   return fract(cos(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float rand3(in vec3 co){
   return fract(sin(dot(co.xyz ,vec3(12.9898,78.233,213.576))) * 43758.5453);
}

float valueNoiseSimple3D(in vec3 vl) {
    const vec2 helper = vec2(0., 1.);
    vec3 grid = floor(vl);
    vec3 interp = smoothstep(vec3(0.), vec3(1.), fract(vl));

    float interpY0 = mix(mix(rand3(grid),
        rand3(grid + helper.yxx),
        interp.x),
        mix(rand3(grid + helper.xyx),
        rand3(grid + helper.yyx),
        interp.x),
        interp.y);

    float interpY1 = mix(mix(rand3(grid + helper.xxy),
        rand3(grid + helper.yxy),
        interp.x),
        mix(rand3(grid + helper.xyy),
        rand3(grid + helper.yyy),
        interp.x),
        interp.y);

    return -1. + 2.*mix(interpY0, interpY1, interp.z);
}

float fractalNoise(in vec3 vl) {
    const float persistance = 2.;
    const float persistanceA = 2.;
    float amplitude = .5;
    float rez = 0.0;
    float rez2 = 0.0;
    vec3 p = vl;

    for (int i = 0; i < OCTAVES / 2; i++) {
        rez += amplitude * valueNoiseSimple3D(p);
        amplitude /= persistanceA;
        p *= persistance;
    }

    float h = smoothstep(0., 1., vl.y*.5 + .5 );
    if (h > 0.01) { // small optimization, since Hermit polynom has low front at the start
        // God is in the details
        for (int i = OCTAVES / 2; i < OCTAVES; i++) {
        rez2 += amplitude * valueNoiseSimple3D(p);
        amplitude /= persistanceA;
        p *= persistance;
        }
        rez += mix(0., rez2, h);
    }

    return rez;
}

void GetQuadInfo( const float vertexIndex, out float x, out float y, out float quadId )
{
  float twoTriVertexIndex = mod( vertexIndex, 6.0 );
  float triVertexIndex = mod( vertexIndex, 3.0 );
  float quadTriIndex = floor(twoTriVertexIndex*0.334);
  float quadVertexIndex = triVertexIndex + quadTriIndex;

  x = mod(quadVertexIndex, 2.);
  y = floor(quadVertexIndex * 0.5);

  quadId = floor( vertexIndex / 6.0 );
}

//todo: DEFINE PROJECTION
mat4 GetProjection(){
  float near = 0.01;
  float far = 10.;
  float aspectRatio = resolution.x / resolution.y;
  float fov = 2.;
  float h = cos(0.5*fov)/sin(0.5*fov);
  float w = h * aspectRatio;
  float a = - (near+far)/(near - far);
  float b = - ((2.*far*near)/(far-near));

  mat4 m = mat4(
    w, 0, 0, 0,
    0, h, 0, 0,
    0, 0, a, 1,
    0, 0, b, 0
  );
    return m;
}

void ProcessBackdrop( float vertexIndex )
{
  float quadX, quadY, quadId;

  GetQuadInfo( vertexIndex, quadX, quadY, quadId );

  //vec2 vDim = vec2( 8.0, 8.0 );

  vec2 vUV;

  vec2 quadTile;
  quadTile.x = mod(quadId, BG_DIM_X);
  quadTile.y = floor(quadId / BG_DIM_X);

  vUV.x = quadX + quadTile.x;
  vUV.y = quadY + quadTile.y;

  vUV /= vec2(BG_DIM_X, BG_DIM_Y);

  gl_Position = vec4( vUV.xy * 2.0 - 1.0, 0.99, 1.0 );

  v_color = vec4( vUV.xy, 0., 1.0 );
}

void ProcessCylinder(float vertexIndex )
{
  float quadX, quadY, quadId;

  GetQuadInfo( vertexIndex, quadX, quadY, quadId );

  vec2 vDim = vec2(DIM_X, DIM_Y);

  vec2 vUV;

  vec2 quadTile;
  quadTile.x = mod(quadId, vDim.x);
  quadTile.y = floor(quadId / vDim.x);

  vUV.x = quadX + quadTile.x;
  vUV.y = quadY + quadTile.y;

  vUV /= vDim;

  float phase = vUV.x * PI * 2.;
  vec3 pos;
  float r = smoothstep(1.,0.,vUV.y);
  r += 0.5;
  r *= 0.25;

  pos.x = sin(phase);
  pos.y = vUV.y - 0.5;
  pos.z = cos(phase);
  pos.xz *= r;

  pos.z += 1.;

  pos += fractalNoise(pos*10.)* 0.05;

  gl_Position = GetProjection() * vec4(pos, 1.0 );

  //vec3 vPos = vec3( vUV.xy * 2.0 - 1.0, 2.0 );
  //vPos.y *= resolution.x / resolution.y;

  v_color = vec4( vUV.xy, 0., 1.0 );
}

void main() {
  float vid = vertexId;
 float bgCount = BG_DIM_X * BG_DIM_Y * 6.;

   if( vid < bgCount )
    {
  ProcessBackdrop(vid);
    }
   else
  {
     vid -= bgCount;
     float cylCount = DIM_X * DIM_Y * 6.;
     if(vid < cylCount) ProcessCylinder(vid);
     //ProcessCylinder(vid);
     //ProcessCylinder(vertexId - bgCount);
  }
  /*
  else if(vertexId - bgCount< DIM_X * DIM_Y * 6.)
  {
    ProcessCylinder(vertexId-bgCount);
  }*/

}