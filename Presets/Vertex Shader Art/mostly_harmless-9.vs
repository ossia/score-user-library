/*{
  "DESCRIPTION": "mostly harmless",
  "CREDIT": "zug (ported from https://www.vertexshaderart.com/art/pd5cBhZ239NhxnEim)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 29897,
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
      "$date": 1590947132680
    }
  }
}*/

#define PI radians(180.)
#define VERTICES_PER_TRI 3
#define MASK 16
#define SCALE 112.0
#define MAX_TRIS 9
#define MAX_NORMALS 12
#define TOTAL_TRI 12
#define VERTS_PER_VEC4 4
#define KP0 mouse.y
#define KP1 mouse.x
#define zoom (mouse.x+mouse.y)
#define KP2 0.
float aspect=resolution.x/resolution.y;
vec4 triangles[MAX_TRIS];
vec3 normals[MAX_NORMALS];

const vec3 masker = vec3(MASK,1.0,MASK*MASK);
vec4 unpackVertex(float a)
{
  vec4 r = vec4(a);
  r.xyz/=masker.yxz;
  return vec4(mod(r.xyz,masker.xxx), 1.0);
}
const float znear=0.001, zfar=1000.0;
const float rangeInv = 1.0 / (znear-zfar);

mat4 persp = mat4(
    1.0 / aspect, 0, 0, 0,
    0, 1.0, 0, 0,
    0, 0, (znear + zfar) * rangeInv, -1,
    0, 0, znear * zfar * rangeInv * 2., 0);

void populate(){

triangles[ 0]=vec4( 0.0, 96.0, 4.0, 91.0);
triangles[ 1]=vec4( 4.0, 96.0, 47.0, 4.0);
triangles[ 2]=vec4( 91.0, 2112.0, 91.0, 96.0);
triangles[ 3]=vec4( 3332.0, 91.0, 2112.0, 3332.0);
triangles[ 4]=vec4( 126.0, 91.0, 47.0, 91.0);
triangles[ 5]=vec4( 1326.0, 2112.0, 3328.0, 3332.0);
triangles[ 6]=vec4( 0.0, 4.0, 3328.0, 3328.0);
triangles[ 7]=vec4( 4.0, 3332.0, 1326.0, 3332.0);
triangles[ 8]=vec4( 1., 42.0, 1326.0, 4.0);

normals[0]=vec3(0.,0.,-1.);
normals[1]=vec3(0.,0.,-1.);
normals[2]=vec3(0.,0.,-1.);
normals[3]=vec3(0.09,0.97,0.19);
normals[4]=vec3(0.27,0.85,0.43);
normals[5]=vec3(0.16,0.90,0.39);
normals[6]=vec3(0.51,0.84,0.10);
normals[7]=vec3(0.,0.80,0.58);
normals[8]=vec3(0.,-1.,0.);
normals[9]=vec3(0.,-1.,0.);
normals[10]=vec3(0.16,-0.98,0.);
normals[11]=vec3(0.15,-0.98,0.03);
}

float getVertex(int target){
  int h= ((target/VERTS_PER_VEC4));
  int n = int(mod(float(target),float(VERTS_PER_VEC4)));
  for(int i=0;i<MAX_TRIS;i++){
    if(i==h){
      vec4 t = triangles[i];
      for(int ii=0;ii<VERTS_PER_VEC4;ii++){
        if(ii==n) return t.x;
        t = t.yzwx;
      }
    }
  }
}

vec3 getNormal(int target){

  for(int i=0;i<=MAX_NORMALS;i++){
    if(i==target){
      return normals[i];

    }
  }
}

#define MSET float s = sin( angle );float c = cos( angle );
mat4 rotX(float angle) { MSET
    return mat4(
      1, 0, 0, 0,
      0, c, s, 0,
      0,-s, c, 0,
      0, 0, 0, 1);
}

mat4 rotY( float angle ) { MSET
    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 1);
}

mat4 rotZ( float angle ) { MSET
    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1);
}

void main() {
  populate();

  int target=int(mod(vertexId,float(TOTAL_TRI*VERTICES_PER_TRI)));
  int target2=int(mod(vertexId,float((TOTAL_TRI*2)*VERTICES_PER_TRI)));
  vec3 normal=normalize(getNormal(target/3));
  gl_Position= (unpackVertex(getVertex(target))-vec4(1.0,4.0,7.5,0.0))/3.0;
  if(target2>=((TOTAL_TRI)*VERTICES_PER_TRI)){
    //Mirror the model in x-axis
    gl_Position.x=-gl_Position.x;
    normal=reflect(normal,vec3(1.,0.,0.));
  }
  mat4 tr=rotX(KP0*2.)*rotZ(KP1)*rotY(sin(time/4.));;
  vec4 n2 =tr*normal.xyzz;n2.w=1.0;
  n2=vec4(dot(n2,vec4(-.8,.8,-.2,1.0)));
  gl_Position=tr*gl_Position;
  v_color = n2/3.0+0.1*(vec4( 1.0,3.0*KP2,.70,1.0));//vec4((vertexId/float(TOTAL_TRI*VERTICES_PER_TRI))+.1,0.0,0.0,1.0);
  v_color.w=1.0;
  gl_Position.z-=8./zoom;
gl_Position = persp * vec4(gl_Position.xyz, 1);

}