/*{
  "DESCRIPTION": "geosphere",
  "CREDIT": "johan (ported from https://www.vertexshaderart.com/art/adr4oWENvpWNLwHJR)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math"
  ],
  "POINT_COUNT": 20000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 115,
    "ORIGINAL_DATE": {
      "$date": 1446315356886
    }
  }
}*/

#define PI 3.14159
#define DIVISIONS 0.
//#DEFINE INDICES {1,4,0,4,9,0,4,5,9,8,5,4,1,8,4,1,10,8,10,3,8,8,3,5,3,2,5,3,7,2,3,10,7,10,6,7,6,11,7,6,0,11,6,1,0,10,1,6,11,0,9,2,11,9,5,2,9,11,2,7};

const float DIM_X = 128.;
const float DIM_Y = 64.;

const float BG_DIM_X = 8.;
const float BG_DIM_Y = 6.;
//#define FIT_VERTICAL
/*
//const int INDICES[60] = int[](
const int INDICES[60] = {
  1,4,0,
  4,9,0,
  4,5,9,
  8,5,4,
  1,8,4,
  1,10,8,
  10,3,8,
  8,3,5,
  3,2,5,
  3,7,2,
  3,10,7,
  10,6,7,
  6,11,7,
  6,0,11,
  6,1,0,
  10,1,6,
  11,0,9,
  2,11,9,
  5,2,9,
  11,2,7
//);
}
*/

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

  /*
  vec3 corners2[12] = vec3[](
    vec3(-X, 0, Z),
    vec3(X, 0, Z),
    vec3(-X, 0, -Z),

    vec3(X, 0, -Z),
    vec3(0, Z, X),
    vec3(0, Z, -X),

    vec3(0, -Z, X),
    vec3(0, -Z, -X),
    vec3(Z, X, 0),

    vec3( -Z, X, 0),
    vec3(Z, -X, 0),
    vec3(-Z, -X, 0)
    );
  */
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

vec3 VolcanoVertexPos(vec2 uv){
  float phase = uv.x * PI * 2.;
  vec3 pos;
  float r = smoothstep(1.,0.,uv.y);
  r += 0.5;
  r *= 0.25;

  pos.x = sin(phase);
  pos.y = uv.y - 0.5;
  pos.z = cos(phase);
  pos.xz *= r;

  pos.z += 1.;

  //pos += fractalNoise(pos*10.)* 0.05;

  return pos;
}

/*
int[] getVertexIndices(float triangleIndex)
{
  int indices[3] = int[](0,0,0);
  return indices;
}
*/

void ProcessGeoSphere(float vertexIndex )
{
  float X = 0.525731112119133606;
  float Z = 0.850650808352039932;

  vec3 corners[12];
  corners[0] = vec3(-X, 0, Z);
  corners[1] = vec3(X, 0, Z);
  corners[2] = vec3(-X, 0, -Z);

  corners[3] = vec3(X, 0, -Z);
  corners[4] = vec3(0, Z, X);
  corners[5] = vec3(0, Z, -X);

  corners[6] = vec3(0, -Z, X);
  corners[7] = vec3(0, -Z, -X);
  corners[8] = vec3(Z, X, 0);

  corners[9] = vec3( -Z, X, 0);
  corners[10] = vec3(Z, -X, 0);
  corners[11] = vec3(-Z, -X, 0);

   vec3 triangles[20];
  triangles[0] = vec3(1,4,0);
  triangles[1] = vec3(4,9,0);
  triangles[2] = vec3(4,5,9);
   //

  //int indices[60] = int[](1,4,0,4,9,0,4,5,9,8,5,4,1,8,4,1,10,8,10,3,8,8,3,5,3,2,5,3,7,2,3,10,7,10,6,7,6,11,7,6,0,11,6,1,0,10,1,6,11,0,9,2,11,9,5,2,9,11,2,7);
  //float array[2] = float[2](1., 1.);

  float vi = mod(vertexIndex, 3.);
  float triIndex = floor(vertexIndex/3.);

  vec3 pos;

  gl_Position = GetProjection() * vec4(pos, 1.0 );

  //vec3 vPos = vec3( vUV.xy * 2.0 - 1.0, 2.0 );
  //vPos.y *= resolution.x / resolution.y;

  //v_color = vec4( vUV.xy, 0., 1.0 );
   v_color = vec4(pos * 0.5 + 0.5, 1.0 );
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
     float geoSphereCount = 20. * pow(4., DIVISIONS) * 3.;
     if(vid < geoSphereCount) ProcessGeoSphere(vid);
  }
}