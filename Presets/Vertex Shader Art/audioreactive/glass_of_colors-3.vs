/*{
  "DESCRIPTION": "glass of colors",
  "CREDIT": "zug (ported from https://www.vertexshaderart.com/art/nQhMRh5xxazydRqaC)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 47881,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 132,
    "ORIGINAL_DATE": {
      "$date": 1598335236769
    }
  }
}*/

//In progress. Based on http://glslsandbox.com/e#40190.0
//Another experiment of 'vertexification' of a fragment shader

#define PI radians(180.)
#define RESOLUTION_MIN min(resolution.x, resolution.y)
#define ASPECT (resolution.xy/RESOLUTION_MIN)

//Shader funcitons
vec2 v(vec2 p,float s){
 return vec2(sin(s*p.y),cos(s*p.x)); //advection vector field
}

vec2 RK4(vec2 p,float s, float h){
 vec2 k1 = v(p,s);
 vec2 k2 = v(p+10.5*h*k1,s);
 vec2 k3 = v(p+0.5*h*k2,s);
 vec2 k4 = v(p+h*k3,s);
 return h/3.*(0.5*k1+k2+k3+0.5*k4);
}

vec3 rainbow(float hue){
 return abs(mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0;
}

//End shader functions

//functions for the shader
float random(in vec2 st) {
 return fract(sin(dot(st, vec2(12.9898, 78.233))) * 43758.545123);
}

float noise1(vec2 st) {
 vec2 i = floor(st);
 vec2 f = fract(st);
 vec2 u = f * f * (3.0 - 2.0 * f);
 return mix(mix(random(i + vec2(0.0, 0.0)),
        random(i + vec2(1.0, 0.0)), u.x),
     mix(random(i + vec2(0.0, 1.0)),
        random(i + vec2(1.0, 1.0)), u.x), u.y);
}

float lines(in vec2 pos, float b) {
 float scale = 10.0;
 pos *= scale;
 return smoothstep(0.0, 0.5 + b * 0.5, abs(sin(pos.x * 3.1415) + b * 2.0) * .5);
}

mat2 rotate2d(float angle) {
 return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

//end functions for the shader

//Functions used for camera

mat4 lookAt(vec3 eye, vec3 target, vec3 up) {
  vec3 zAxis = normalize(eye - target);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 0,
    yAxis, 0,
    zAxis, 0,
    eye, 1);
}

mat4 cameraLookAt(vec3 eye, vec3 target, vec3 up) {
  #if 1
  return inverse(lookAt(eye, target, up));
  #else
  vec3 zAxis = normalize(target - eye);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 0,
    yAxis, 0,
    zAxis, 0,
    -dot(xAxis, eye), -dot(yAxis, eye), -dot(zAxis, eye), 1);
  #endif

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

vec2 rotate(vec2 f, float deg)
{
 return vec2(f.x * cos(deg) - f.y * sin(deg), f.x * sin(deg) + f.y * cos(deg));
}

//End functions used for camera

void main ()
{
   float finalDesiredPointSize = 3.;
   float maxFinalSquareSideSize = floor(sqrt(vertexCount));
   float finalMaxVertexCount = maxFinalSquareSideSize*maxFinalSquareSideSize;

  //first the number of elements in a line
  float across = floor(maxFinalSquareSideSize *resolution.x/resolution.y);
  finalDesiredPointSize = resolution.x/across;
  //we want to keep the resolution >> across/down must be the same as resolution.x/resolution.y
  //across = across*resolution.x/resolution.y;

  //then the number of possible lines with the given vertexCount
  float down = floor(finalMaxVertexCount / across);

  //we can now calculate the final number of elements
  float finalVertexCount = across*down;

  //and the consequent finalVertexId
  float finalVertexId = mod(vertexId,finalVertexCount);

  //Now we calculate the position of the elements based on their finalVertexId
  float x = mod(finalVertexId, across);
  float y = floor(finalVertexId / across);

  float u = (x /across);
  float v = (y /down);

  float u0 = (u * (across*finalDesiredPointSize/resolution.x));
  float v0 = (v * (across*finalDesiredPointSize/resolution.x ));

  float ux = u0 - 0.5*(across*finalDesiredPointSize/resolution.x);
  float vy = v0- 0.5*(across*finalDesiredPointSize/resolution.x);;

    if(u>0.5)
    u = 1.-u;
 if(v>0.5)
    v = 1.- v;

  float udnd = u;
  if(u>0.5)
    udnd = 1.-u;

  float snd = texture(sound, vec2(0., 0.0)).r;

 vec2 fragcoord = vec2(x,y);
    vec2 newResolution = vec2(across, down);

  vec2 aspect = resolution/min(resolution.x, resolution.y);
  vec2 uv = vec2(u,v);
  vec2 FragCoord = vec2(u*cos(time),v-1.4);
 //vec2 uv = 2.*gl_FragCoord.xy/resolution.y-vec2(resolution.x/resolution.y,1);
 vec2 pos = normalize(vec2(u,v));//

  float s = 2.;
 float h = 1.0;
 vec2 range = aspect * sqrt(2.);
     for(int i = 0; i<5*8; i++) {
  float hh = h * log(1./(exp(2.*sin(time*0.5 + pos.x*aspect.x + pos.y*aspect.y + float(i) * 0.1))))/5.;
   uv+=RK4(uv,s,hh);
  s*=1.25;
  h/=1.25;
     }
 //gl_FragColor = vec4(rainbow(time*0.1 + floor(length(uv)*10.)/10.),1); //centered rainbow with 10 visible rings

  v_color = vec4(rainbow(time*.1 - floor(length(uv)*(3.+15.))/10.),1.); //centered rainbow with 10 visible rings

  //camera
  float r = 1.3;
  float tm = .5 *time;
  float tm2 = 0.25*time;
  mat4 mat = persp(radians(60.0), resolution.x /resolution.y *-1., .3-sin(tm),2.0);
  //vec3 eye = vec3(cos(tm) * r/10., 0.3, r);
  vec3 eye = vec3(cos(tm) * r, sin(tm * 0.93) * r, sin(tm) * r);
  vec3 target = vec3(0.,-0.001,0.1);
  vec3 up = vec3(0., sin(tm2), cos(tm2));

  mat *= cameraLookAt(eye, target, up);

  //gl_PointSize = 4.;//finalDesiredPointSize;

  //v_color = vec4(col, 1);
  float depth = (v_color.x+v_color.y+v_color.z)/3.;
  float depthFactor = 0.;

  //if(depth>=0.5)
  {
    depthFactor = depth;
  }

  vec4 finalPos = vec4(ux, vy, -snd*depth , .9);

  gl_Position = mat*finalPos;
  gl_PointSize = 2.;///abs(gl_Position.z);

  //v_color = vec4(1.,1.,1.,1.);
}


// Removed built-in GLSL functions: inverse