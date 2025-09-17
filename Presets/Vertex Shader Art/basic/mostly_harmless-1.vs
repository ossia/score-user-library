/*{
  "DESCRIPTION": "mostly harmless",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/57eTciQiKd6wT2ndd)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 60,
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
    "ORIGINAL_VIEWS": 69,
    "ORIGINAL_DATE": {
      "$date": 1589157387084
    }
  }
}*/

#define PI radians(180.)
#define VERTICES_PER_TRI 3

#define AND(a,x) int(floor(x - (a * 16.0)))
#define MASK 1024.0
#define SCALE 112.0
#define MAX_TRIS 32
#define TOTAL_TRI 21

float aspect=resolution.x/resolution.y;
vec3 triangles[MAX_TRIS];
mat4 indices[4];

const vec3 masker = vec3(MASK,1.0,MASK*MASK);
vec4 unpackVertex(float a)
{
  vec4 r = vec4(a);
  r.xyz/=masker.yxz;
  return vec4(mod(r.xyz,masker.xxx), 1.0);
}
mat4 rotX(float angle) {

    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      1, 0, 0, 0,
      0, c, s, 0,
      0,-s, c, 0,
      0, 0, 0, 1);
}

void populate(){

#define V1 18451.0
#define V2 7169.0
#define V3 46.0
#define V4 22588.0
#define V5 75.0
#define V6 18534.0
#define V7 7288.0
#define V8 54525998.0
#define V9 54526027.0
#define V10 19930228.0
#define V11 19930116.0
#define V12 31473724.0

triangles[0]=vec3(V1,V2,V3);
triangles[1]=vec3(V3,V1,V4);
triangles[2]=vec3(V4,V3,V5);
triangles[3]=vec3(V5,V4,V6);
triangles[4]=vec3(V6,V5,V7);
triangles[5]=vec3(V3,V8,V5);
triangles[6]=vec3(V8,V9,V5);
triangles[7]=vec3(V10,V5,V9);
triangles[8]=vec3(V7,V10,V5);
triangles[9]=vec3(V11,V3,V8);
triangles[10]=vec3(V2,V11,V3);
triangles[11]=vec3(V12,V9,V8);
triangles[12]=vec3(V12,V4,V6);
triangles[13]=vec3(V12,V1,V4);
triangles[14]=vec3(V12,V6,V9);
triangles[15]=vec3(V12,V8,V1);
triangles[16]=vec3(V9,V6,V10);
triangles[17]=vec3(V8,V1,V11);
triangles[18]=vec3(V7,V6,V10);
triangles[19]=vec3(V2,V1,V11);
}

float getVertex(int target){
  int h= ((target/VERTICES_PER_TRI));
  for(int i=0;i<MAX_TRIS;i++){
    if(i==h){
      vec3 t = triangles[i];
      int n= int(mod(float(target),3.0));
      for(int ii=0;ii<3;ii++){
        if(ii==n) return t.x;
       t = t.yzx;
      }

    }
  }
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

void main() {
  populate();

  int target=int(mod(vertexId,float(TOTAL_TRI*VERTICES_PER_TRI)));
  gl_Position= (unpackVertex(getVertex(target))-vec4(60.0,11.0,30.0,0.0))/10.0;

  gl_Position=rotY(time/5.0)*rotZ(sin(time)/2.0)*gl_Position;
  v_color = vec4((vertexId/float(TOTAL_TRI*VERTICES_PER_TRI))+.1,0.0,0.0,1.0);

  gl_Position.z-=10.0;
  gl_Position = persp(PI*0.5, resolution.x/resolution.y, 0.1, 100.0) * vec4(gl_Position.xyz, 1);

}