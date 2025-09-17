/*{
  "DESCRIPTION": "mostly harmless",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/Cj2C3bSnE4yoFBfHp)",
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
    "ORIGINAL_VIEWS": 51,
    "ORIGINAL_DATE": {
      "$date": 1589155936765
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

triangles[0]=vec3(18451.0,7169.0,46.0);
triangles[1]=vec3(46.0,18451.0,22588.0);
triangles[2]=vec3(22588.0,46.0,75.0);
triangles[3]=vec3(75.0,22588.0,18534.0);
triangles[4]=vec3(18534.0,75.0,7288.0);
triangles[5]=vec3(46.0,54525998.0,75.0);
triangles[6]=vec3(54525998.0,54526027.0,75.0);
triangles[7]=vec3(19930228.0,75.0,54526027.0) ;
triangles[8]=vec3(7288.0,19930228.0,75.0);
triangles[9]=vec3(19930116.0,46.0,54525998.0);
triangles[10]=vec3(7169.0,19930116.0,46.0) ;
triangles[11]=vec3(31473724.0,54526027.0,54525998.0) ;
triangles[12]=vec3(31473724.0,22588.0,18534.0) ;
triangles[13]=vec3(31473724.0,18451.0,22588.0) ;
triangles[14]=vec3(31473724.0,18534.0,54526027.0) ;
triangles[15]=vec3(31473724.0,54525998.0,18451.0) ;
triangles[16]=vec3(54526027.0,18534.0,19930228.0) ;
triangles[17]=vec3(54525998.0,18451.0,19930116.0) ;
triangles[18]=vec3(7288.0,18534.0,19930228.0) ;
triangles[19]=vec3(7169.0,18451.0,19930116.0) ;
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