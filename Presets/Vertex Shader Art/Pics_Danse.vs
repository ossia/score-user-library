/*{
  "DESCRIPTION": "Pics Danse",
  "CREDIT": "aiekick (ported from https://www.vertexshaderart.com/art/SAToMsqc7PybLLEc2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 756,
    "ORIGINAL_LIKES": 4,
    "ORIGINAL_DATE": {
      "$date": 1530027655061
    }
  }
}*/

// Created by Stephane Cuillerdier - Aiekick/2018 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

////////////////////////////////////////////////////////////
#define PI radians(180.)
mat4 persp(float fov, float aspect, float zNear, float zFar);
mat4 lookAt(vec3 eye, vec3 target, vec3 up);
mat4 inverse(mat4 m);
mat4 cameraLookAt(vec3 eye, vec3 target, vec3 up);
////////////////////////////////////////////////////////////

mat3 RotX(float a){return mat3(1.,0.,0.,0.,cos(a),-sin(a),0.,sin(a),cos(a));}
mat3 RotY(float a){return mat3(cos(a),0.,sin(a),0.,1.,0.,-sin(a),0.,cos(a));}
mat3 RotZ(float a){return mat3(cos(a),-sin(a),0.,sin(a),cos(a),0.,0.,0.,1.);}
mat4 Trans(float x, float y, float z){return mat4(1,0,0,0,0,1,0,0,0,0,1,0,x,y,z,1);}

#define _2pi 6.2831853
#define _pi 3.1415926
#define _05pi 1.5707963

// based on http://vincentwoo.com/2013/03/08/above-and-beyond-the-affirm-job-puzzle/
vec2 getHexPos(float vVertexId, float vPolySize, float vHexSpace)
{
 float indexTri = floor(vVertexId / 3.);
 float indexCircle = floor(indexTri / vPolySize);

 if (indexCircle == 0.) return vec2(0);

 float ringCircle = floor(sqrt((4. * indexCircle - 1.) / 12.0) - 0.5) + 1.0;;

 float circleOffset = (3. * pow(ringCircle,2.) + 3. * ringCircle + 1.) - indexCircle;

 float side_number = floor(circleOffset / ringCircle);
 float side_offset = mod(circleOffset, ringCircle);

 float as = _2pi / vPolySize;

 float a = as * side_number;
 vec2 hex0 = vec2(cos(a),sin(a));

 a = as * mod((side_number + 1.), vPolySize);
 vec2 hex1 = vec2(cos(a),sin(a)) - hex0;

 return ((hex0 * ringCircle) + (hex1 * side_offset)) * vHexSpace;
}

void main()
{
   float t = time * 5.;

   gl_PointSize = 3.;

 float polySize = floor(abs(mouse.x * 3.)+3.);
 float hexSpace = cos(radians(45.))*2.;

 float off = 360.0 * time * 0.2;
 float astep = -_2pi / polySize;
 float angleOffset = cos(radians(off))*2.;
 float indexTri = floor(vertexId / 3.);
 float indexShape = floor(indexTri / polySize);

 float angle0 = indexTri * astep + angleOffset;
 float angle1 = (indexTri + 1.) * astep + angleOffset;

 float index = mod(vertexId, 3.);

 vec3 p = vec3(0);

 if (index == 0.) p = vec3(cos(angle0), -10, sin(angle0));
 else if (index == 1.) p = vec3(cos(angle1), -10, sin(angle1));
 else if (index == 2.) p = vec3(0,1,0);

 vec3 col = vec3(0,p.y,0);

 //p.xz *= 2.;
    p.xz -= getHexPos(vertexId, polySize, hexSpace);

 p.y += cos((indexShape * 2. + t)) * 2.;

 ///////////////////////////////////////////////////////////////////////////////////////
 float ca = -0.7;
 float ce = 1.57;
 float cd = 10.8;
 vec3 eye = vec3(0.2, 1, 0.) * cd;
 vec3 target = vec3(0, 0, 0);
 vec3 up = vec3(0, 1, 0);

 mat4 camera = persp(45. * PI / 180., resolution.x / resolution.y, 0.1, 10000.);
 camera *= cameraLookAt(eye, target, up);

 gl_Position = camera * vec4(p, 1);

   v_color = vec4(clamp(col,0.,1.), 1);
}

////////////////////////////////////////////////////////////

mat4 persp(float fov, float aspect, float zNear, float zFar) {
 float f = tan(PI * 0.5 - 0.5 * fov);
 float rangeInv = 1.0 / (zNear - zFar);

 return mat4(
  f / aspect, 0, 0, 0,
  0, f, 0, 0,
  0, 0, (zNear + zFar) * rangeInv, -1,
  0, 0, zNear * zFar * rangeInv * 2., 0);
}

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
////////////////////////////////////////////////////////////
// Removed built-in GLSL functions: inverse