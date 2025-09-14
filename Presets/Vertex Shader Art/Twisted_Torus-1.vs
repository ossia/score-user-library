/*{
  "DESCRIPTION": "Twisted Torus - Use mouse to control the shape",
  "CREDIT": "aiekick (ported from https://www.vertexshaderart.com/art/JscBDhcAFypHdaMCm)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 12000,
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
    "ORIGINAL_VIEWS": 270,
    "ORIGINAL_DATE": {
      "$date": 1519246793082
    }
  }
}*/

// Created by Stephane Cuillerdier - Aiekick/2017 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// mouse axis x => contorl section compelxity
// mouse axis y => controe torus complexity

mat4 persp(float fov, float aspect, float zNear, float zFar);
mat4 cameraLookAt(vec3 eye, vec3 target, vec3 up);

void main()
{
   gl_PointSize = 3.;

 float pi = radians(180.);
 float pi2 = radians(360.);

   vec2 mo = 0.5 - mouse;

 // vars
 // count point : 6 * quadsPerPolygon * countPolygon => here 3600
 float quadsPerPolygon = clamp(floor(10. * (mo.x*0.5+0.5)), 3., 10.);
 float countPolygon = clamp(floor(200. * (mo.y*0.5+0.5)), 3., 200.);
 float radius = 20.;
 float thickNess = 5.;
 float zoom = 2.;

   float countMax = 6. * quadsPerPolygon * countPolygon;

 float index = mod(vertexId, 6.);

 float indexQuad = floor(vertexId / 6.);
 float asp = pi * 2.0 / quadsPerPolygon; // angle step polygon
 float ap0 = asp * indexQuad; // angle polygon 0
 float ap1 = asp * (indexQuad + 1.); // angle polygon 0

 float indexPolygon = floor(indexQuad / quadsPerPolygon);
 float ast = pi * 2.0 / countPolygon; // angle step torus
 float at0 = ast * indexPolygon; // angle torus 0
 float at1 = ast * (indexPolygon + 1.); // angle torus 1

   vec2 st = vec2(0);

   // triangle 1
 if (index == 0.) st = vec2(ap0, at0);
 if (index == 1.) st = vec2(ap1, at0);
 if (index == 2.) st = vec2(ap1, at1);

 // triangle 2
 if (index == 3.) st = vec2(ap0, at0);
 if (index == 4.) st = vec2(ap1, at1);
 if (index == 5.) st = vec2(ap0, at1);

   vec3 p = vec3(cos(st.x),st.y,sin(st.x));

   // twist
 float ap = st.y - cos(st.y) + time;

   // polygon
 p.xz *= thickNess;
 p.xz *= mat2(cos(ap), sin(ap), -sin(ap), cos(ap));

 // torus
 p.x += radius;
 float at = p.y; p.y = 0.0;
 p.xy *= mat2(cos(at), sin(at), -sin(at), cos(at));

 // camera
 float ca = 0.5;//time * 0.1;
 float cd = 100.;
 vec3 eye = vec3(sin(ca), 0., cos(ca)) * cd;
 vec3 target = vec3(0, 0, 0);
 vec3 up = vec3(0, 1, 0);
 mat4 camera = persp(45. * pi / 180., resolution.x / resolution.y, 0.1, 10000.) *
      cameraLookAt(eye, target, up);

   // vertex position
   if (vertexId < countMax)
    {
    gl_Position = camera * vec4(p,1);
    }
   else
   {
       gl_Position = vec4(0,0,0,0);
   }

 // face color
 indexQuad = mod(indexQuad, quadsPerPolygon);
 v_color = cos(vec4(10,20,30,1) + indexQuad);
 v_color = mix(v_color, vec4(normalize(p) * 0.5 + 0.5, 1), .5);
   v_color.a = 1.0;
}

//////////////////////////////////////////////////////////////////////////

#define PI radians(180.)

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