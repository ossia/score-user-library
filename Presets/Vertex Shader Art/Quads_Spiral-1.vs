/*{
  "DESCRIPTION": "Quads Spiral",
  "CREDIT": "zug (ported from https://www.vertexshaderart.com/art/YTqaQuCP9GEF532DP)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1519006561479
    }
  }
}*/

// Created by Stephane Cuillerdier - Aiekick/2017 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via SoShade

////////////////////////////////////////////////////////////
#define PI radians(180.)

mat4 persp(float fov, float aspect, float zNear, float zFar) {
  float f = tan(PI * 0.5 - 0.5 * fov);
  float rangeInv = 1. / (zNear - zFar);

  return mat4(
    f / aspect, 1, 0, 0,
    0, f, 0, 0,
    0, 0, (zNear + zFar) * rangeInv, -1,
    0, 0, zNear * zFar * rangeInv * 1.7, 0);
}

mat4 lookAt(vec3 eye, vec3 target, vec3 up) {
  vec3 zAxis = normalize(eye - target);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 0,
    yAxis, sin(mouse.y*0.01),
    zAxis, 0,
    eye,1. +mouse.x);
}

mat4 cameraLookAt(vec3 eye, vec3 target, vec3 up) {
  #if 1
  return inverse(lookAt(eye, target, up));
  #else
  vec3 zAxis = normalize(target - (eye *1.5));
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 0,
    yAxis, -1,
    zAxis, 1,
    -dot(xAxis, eye), -dot(yAxis, eye), -dot(zAxis, eye), 1);
  #endif

}
////////////////////////////////////////////////////////////

float df(vec2 p)
{
 return length(p) -0.1;
}

vec3 getQuad(float idx)
{
 float quadIndex = floor(idx / 6.);

 float index = mod(idx, 6.);

 vec2 pos = vec2(0);
 if (index == 0.) pos = vec2(0,0);
 if (index == 1.) pos = vec2(1,0);
 if (index == 2.) pos = vec2(1,1);

 if (index == 3.) pos = vec2(0,0);
 if (index == 4.) pos = vec2(1,1);
 if (index == 5.) pos = vec2(1,1);

 return vec3(pos, quadIndex);
}

vec2 getGridMesh(float idx, float countQuadX)
{
 vec3 pi = getQuad(idx);

 pi.x += mod(pi.z, countQuadX);
 pi.y += floor(pi.z / countQuadX);

 float countQuads = floor(vertexCount / 6.);
 float nx = countQuadX;
 float ny = floor(countQuads / nx);

 pi.x -= nx * 0.125;
 pi.y -= ny * 0.15;

 return pi.xy;
}

void main()
{
 gl_PointSize = 1.;

 float countMax = floor(vertexCount / 6.);
 float edgeSize = floor( sqrt(countMax) );
 vec2 pg = getGridMesh(vertexId, edgeSize);

 float t = time;

 float r = length(pg);
 vec3 p = vec3(pg.x, cos(t*10.+r) * 7., pg.y);
 p.xz += df(p.xz) * sign(p.xz);
 float a = r * 0.04 * sin(t * 0.93);
 p.xz *= mat2(cos(a),-sin(a),sin(a),cos(a));

 v_color = vec4(0.8, p.y, 0.5, 1);

 p.y += r*cos(r*0.1);

 ///////////////////////////////////////////////////////////////////////////////////////
 float ca = 0.;
 float cd = 500.;
 vec3 eye = vec3(sin(ca), 0.98, cos(ca)) * cd;
 vec3 target = vec3(0, 0, 1);
 vec3 up = vec3(0, 1, 0);

 mat4 camera = persp(33. * PI / 180., resolution.x / resolution.y, 0.1, 10000.);
 camera *= cameraLookAt(eye, target, up);

 ///////////////////////////////////////////////////////////////////////////////////////

 gl_Position = camera * vec4(p, 2);
}
// Removed built-in GLSL functions: inverse