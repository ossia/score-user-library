/*{
  "DESCRIPTION": "wave ",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/PNhE8dDWq3i4kPX64)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 60000,
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
    "ORIGINAL_VIEWS": 107,
    "ORIGINAL_DATE": {
      "$date": 1647203461628
    }
  }
}*/

#define pi acos(-1.)

mat4 porj(float l, float r, float b, float t, float n, float f){
  return mat4(
    2./(r-l),0,0 ,0./*-(r+l)/(r-l)*/,
    0,2./(t-b),0 ,0./*-(t+b)/(t-b)*/,
    0,0,-2./(f-n),-(f+n)/(f-n),
    0,0,0,1
  );
}

mat4 mov(vec3 p){
  return mat4(
    1,0,0,0,
    0,1,0,0,
    0,0,1,0,
    p ,1
  );
}

mat4 rotz(float t){
  float s=sin(t), c=cos(t);
  return mat4(
    c,-s,0,0,
    s,c,0,0,
    0,0,1,0,
    0,0,0,1
  );
}

mat4 roty(float t){
  float s=sin(t), c=cos(t);
  return mat4(
    c,0,s,0,
    0,1,0,0,
    -s,0,c,0,
    0,0,0,1
  );
}

mat4 rotx(float t){
  float s=sin(t), c=cos(t);
  return mat4(
    1,0,0,0,
    0,c,-s,0,
    0,s,c,0,
    0,0,0,1
  );
}

void getMesh(out float x, out float y, out float s){
  float step6 = mod(vertexId, 6.);
  float step3 = mod(vertexId, 3.);
  float temp = step3;
  if(step6 >= 3.){
    temp ++;
  }
  if(temp < 0.5){
    x = 0.;
    y = 0.;
  }
  else if(temp < 1.5){
    x = 1.;
    y = 0.;
  }
  else if(temp < 2.5){
    x = 0.;
    y = 1.;
  }
  else if(temp < 3.5){
    x = 1.;
    y = 1.;
  }
  s = floor(vertexId/6.);
}

float f(vec2 uv ){
  //return (-pow(uv.x,2.)-pow(uv.y,2.))+1.;
  return 0.07+0.07*sin(time-length(5.*pi*uv));
}

void main() {
  float posx, posy, posStep;

  getMesh(posx, posy, posStep);

  vec2 v8 = vec2(100., 100.);
  vec2 uv;
  vec3 vuv;

  uv.x = mod(posStep, v8.x);
  uv.y = floor(posStep/ v8.y);

  vuv.x = posx + uv.x;
  vuv.y = posy + uv.y;

  vuv.xy = vuv.xy * (1. / v8);
  vuv.xy = vuv.xy * 2. - 1.;

  vuv.z = f(vuv.xy);

  mat4 M = mov(vec3(0.,0.,0.)) * rotx(2.*mouse.y) * roty(0.) * rotz(-2.*mouse.x);
  mat4 V = mov(vec3(0.,-0.5,-2)) * rotx(pi/2.) * roty(0.) * rotz(0.);
  mat4 P = porj(0., 1., 0., 1., 1., 100000.0);

  gl_Position = P*V*M* vec4(vuv,1);
  gl_PointSize = 8.;

  vec3 normal = cross(vec3(1,0,vuv.xy*vuv.z),vec3(0,1,vuv.yx*vuv.z));
  vec3 pos_light1 = normalize(vuv-vec3(5.*cos(1.7),5.*-sin(1.7),-1.));
  float light1 = max(0.0,dot(pos_light1, normal))*2.;
  vec3 color = vec3(.3,.5,.8)*light1;

  v_color = vec4(color,1.);
}