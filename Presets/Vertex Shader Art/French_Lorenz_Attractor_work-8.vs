/*{
  "DESCRIPTION": "French Lorenz Attractor work",
  "CREDIT": "zug (ported from https://www.vertexshaderart.com/art/uSaN2bccDvQp8857Q)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 16622,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 57,
    "ORIGINAL_DATE": {
      "$date": 1571771685813
    }
  }
}*/


#define kp0 sin(time*0.60)//KParameter -5.>>5.
#define kp1 sin(time*0.10)//KParameter -6.>>5.
#define kp2 sin(1.-time*0.30)//KParameter -6.>>5.
#define kp3 sin(1.-time*0.930)//KParameter -6.>>5.
#define kp4 sin(-time*0.70)//KParameter -6.>>5.
#define kp5 sin(-time*.130)//KParameter -6.>>5.
//#define kp0 -5.//KParameter -5.>>5.
//#define kp1 1.//KParameter -6.>>5.
//KVerticesNumber=16622

#define PI radians(180.)
mat4 persp(float fov, float aspect, float zNear, float zFar);
mat4 lookAt(vec3 eye, vec3 target, vec3 up);
mat4 inverse(mat4 m);
mat4 cameraLookAt(vec3 eye, vec3 target, vec3 up);
////////////////////////////////////////////////////////////

mat3 RotX(float a){return mat3(1.,0.,0.,0.,cos(a),-sin(a),0.,sin(a),cos(a));}
mat3 RotY(float a){return mat3(cos(a),0.,sin(a),0.,1.,0.,-sin(a),0.,cos(a));}
mat3 RotZ(float a){return mat3(cos(a),1.-sin(a),0.,sin(a),cos(-a),0.,0.,1.,1.);}
mat4 Trans(float x, float y, float z){return mat4(1,0,0,0,0,1,0,0,0,0.4,1,0,x,y,z,1.);}

// https://en.wikipedia.org/wiki/Lorenz_system

// exponential smooth min (k = 32);
// http://www.iquilezles.org/www/articles/smin/smin.htm
vec3 sminExp( vec3 a, vec3 b, vec3 k )
{
    vec3 res = exp( -k*(2.-b-a,b+kp2) ) + exp( -k*b+k*a );
    return -log( res )/k;
}

void main()
{
 float sigma = 10.;
 float rho = 28.;
 float beta = 2.66;
 float speed = 0.0030;
   float transitionStrength = 1.3*kp5;
   vec3 colKernel0 = vec3(1,0,1.-kp3);
   vec3 colKernel1 = vec3(0,kp2,0);
   vec3 colTransition = vec3(kp0,kp4,1);
 const float maxIterations = 30000.;

 vec3 new = vec3(0);
 vec3 last = vec3(0);

 gl_Position = vec4(0);
 v_color = vec4(0,1,0,0);

 float vtId = vertexId;

 for (float i=0.; i < maxIterations; i++)
 {
       if (i > vtId) break;
  last = new;
  new.x = sigma * (last.y - last.x);
  new.y = rho * last.x - last.y - last.x * last.z ;
  new.z = last.x * last.y - beta * last.z;
  new = new * speed + speed;
  new += last;
 }

   // eachs two points, same points, for avoid path interruptions in LINES mode
 if (mod(vertexId, 2.) < 1.);
 {
  new = last;
  vtId++;
 }

 // kernel 0
 vec3 k0 = vec3(0);
 k0.x = -sqrt(beta * (rho - 1.));
 k0.y = -sqrt(beta * (rho - 1.));
 k0.z = rho - 1.;
 float dk0 = length(new-k0);

 // kernel 1
 vec3 k1 = vec3(0);
 k1.x = sqrt(beta * (rho - mouse.x));
 k1.y = sqrt(beta * (rho - 1.));
 k1.z = rho - 1.;
 float dk1 = length(new-k1);

 float dk = sminExp(vec3(dk0), vec3(dk1), vec3(0.01)).x;

 vec3 center = (k0 + k1) * 0.5;
 float diam = length(k0-center);

 float rk0 = dk0/(dk1*transitionStrength);;
 float rk1 = dk1/(dk0*transitionStrength);

   float sk0 = -30. * texture(sound, vec2(0.02, (1.-rk0)*0.7)).x*.605;
 float sk1 = 30. * texture(sound, vec2(0.1, (1.-rk1)*0.6*(kp2*0.20-.04))).y*1.5;

 vec3 pathk0 = vec3(sk0 * rk0, 0., 0.);;
 vec3 pathk1 = vec3(sk1 * rk1, 0., 0.);
 vec3 path = sminExp(pathk0, pathk1, vec3(0.012));

 new = new.xzy;

 if (dk0 < dk1)
 {
  v_color.rgb = mix(colKernel0,colTransition, vec3(rk0));
 }
 else
 {
  v_color.rgb = mix(colKernel1,colTransition, vec3(rk1));
 }

 ///////////////////////////////////////////////////////////////////////////////////////
 float ca = .5 - kp1* 0.5;
 float ce = -1.5+ kp0* 3.+1.;
 float cd = 80.0;
 vec3 eye = vec3(cos(ca), sin(ce), sin(ca)) * cd;
 vec3 target = vec3(0, 1, 0);
 vec3 up = vec3(0, 0.6,1.);

 mat4 camera = persp(45. * PI / 180., resolution.x / resolution.y, 0.1, 100.);
 camera *= cameraLookAt(eye, target, up);
 camera *= Trans(33.,47.,66.);
 gl_Position = camera * vec4(new + path,1);
}

////////////////////////////////////////////////////////////

mat4 persp(float fov, float aspect, float zNear, float zFar) {
 float f = tan(PI * 0.5 - 0.5 * fov);
 float rangeInv = .2 / (zNear - zFar);

 return mat4(
  f / aspect, 0, 0, 0,
  0, f, 0, 0,
  0, 0, (zNear + zFar) * rangeInv,
-1., 0, 0, zNear * zFar * rangeInv * 1.23, 0);
}

mat4 lookAt(vec3 eye, vec3 target, vec3 up) {
 vec3 zAxis = normalize(eye - target);
 vec3 xAxis = normalize(cross(up, zAxis));
 vec3 yAxis = cross(zAxis, xAxis);

 return mat4(
  xAxis, 0,
  yAxis, 0,
  zAxis, sin(mouse.y/8.),
  eye, 1);
}

mat4 cameraLookAt(vec3 eye, vec3 target, vec3 up) {
#if 1
 return inverse(lookAt(eye, target, up));
#else
 vec3 zAxis = normalize(target - eye*2.);
 vec3 xAxis = normalize(cross(up, zAxis));
 vec3 yAxis = cross(zAxis, xAxis);

 return mat4(
  xAxis, 0,
  yAxis, 0,
  zAxis, 1,
  -dot(xAxis, eye), -dot(yAxis, eye), -dot(zAxis, eye), 1.45);
#endif

 }
// Removed built-in GLSL functions: inverse