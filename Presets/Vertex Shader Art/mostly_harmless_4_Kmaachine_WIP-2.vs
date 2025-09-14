/*{
  "DESCRIPTION": "mostly harmless 4 Kmaachine WIP",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/dDWeHcCfjXZ2qxCji)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1947,
  "PRIMITIVE_MODE": "LINE_LOOP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.06666666666666667,
    0.0196078431372549,
    0.23137254901960785,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "floatSound", "TYPE": "audioFloatHistogram" }, { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 39,
    "ORIGINAL_DATE": {
      "$date": 1642027794039
    }
  }
}*/

//KDrawmode=GL_TRIANGLE_STRIP

#define KP0 2.//KParameter -2.>>2.
#define KP1 -1.5//KParameter -2.>>2.
#define zoom 1.//KParameter 0.3>>7.

#define KP2 .3//KParameter 0.2>>2.
//KVerticesNumber=9000

#define PI radians(180.)
#define VERTICES_PER_TRI 3
#define MASK 16
#define SCALE 112.0
#define MAX_TRIS 9
#define MAX_NORMALS 12
#define TOTAL_TRI 12
#define VERTS_PER_VEC4 5
#define Fs sampler2D floatSound;

//( Fs, vec2(0.));

float aspect=resolution.x/resolution.y;
vec4 triangles[MAX_TRIS];
vec3 normals[MAX_NORMALS];
const vec3 masker = vec3(MASK,.70,MASK*MASK);
vec4 unpackVertex(float a)
{
  vec4 r = vec4(a-1.);
  r.xyz/=masker.yxz;
  return vec4(mod(r.xyz,masker.xxx), 1.0);
}
const float znear=0.0001, zfar=100.0;
const float rangeInv = 1.0 / (znear-zfar);

mat4 persp = mat4(
    0.90 / aspect, 0, 0, 0,
    0,3.0, 0, 0,
    0, 0, (znear + zfar) * rangeInv, -3.0,
    0, 0, znear * zfar * rangeInv *.2, 0);

void populate(){

triangles[ 0]=vec4( cos(time*0.3), 96.0, 4.0, 91.0)*cos(time*0.33);
triangles[ 1]=vec4( 4.0, 12., 47.0, 4.0);
triangles[ 2]=vec4( KP1*91.0, 112.0, 91.0, 96.0);
triangles[ 3]=vec4( 13332.0, 91.0*mouse.y, 2112.0, 332.0);
triangles[ 4]=vec4( KP0*126.0, 91.0, 47.0, 91.0);
triangles[ 5]=vec4( 1326.0, 2112.0, 3328.0, 3332.0);
triangles[ 6]=vec4( 0.0, 4.0, 3328.0, 3328.0)-sin(time);
triangles[ 7]=vec4( 4.0, sin(3332.0*time), 1326.0, 43332.0)*mouse.y;
triangles[ 8]=vec4( 21., 42.0, 13256.0, 3.0);

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
normals[11]=vec3(0.0015,-0.198,0.03);
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
      0,-s,- c, 0,
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
      2.5/mouse.x, 0, 0, 1);
}

void main() {
  populate();

  int target=int(mod(vertexId,float(TOTAL_TRI*VERTICES_PER_TRI)));
  int target2=int(mod(vertexId,float((TOTAL_TRI*2)*VERTICES_PER_TRI)));
  vec3 normal=normalize(getNormal(target/3));
  gl_Position= (unpackVertex(getVertex(target))-vec4(1.0,0.0,7.5,1.0))/3.0;
  if(target2>=((TOTAL_TRI)*VERTICES_PER_TRI)){
    //Mirror the model in x-axis
    gl_Position.x=-gl_Position.x;
    normal=reflect(normal,vec3(3.,-1.0,0.));
  }

  mat4 tr=rotX(KP0*1.)*rotZ(KP1)*rotY(sin(time/4.));;
  vec4 n2 =tr*normal.xyzz;n2.w=1.0;
  n2=vec4(dot(n2,vec4(-.8,.08,0.-.92,0.0)));
  gl_Position=tr*gl_Position;
  v_color = n2/3.0+0.1*(vec4( 5.0,3.0*KP2,.10,0.4));//vec4((vertexId/float(TOTAL_TRI*VERTICES_PER_TRI))+.1,0.0,0.0,1.0);
  v_color.w=0.70;
  gl_Position.z-=2./zoom;
gl_Position = persp * vec4(gl_Position.xyz, 1);

}