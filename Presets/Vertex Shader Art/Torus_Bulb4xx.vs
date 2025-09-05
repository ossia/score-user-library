/*{
  "DESCRIPTION": "Torus Bulb4xx",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/NCmuezkb94xMJ4gtR)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 32356,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.00784313725490196,
    0.00784313725490196,
    0.00784313725490196,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 87,
    "ORIGINAL_DATE": {
      "$date": 1510069672714
    }
  }
}*/

//KDrawmode=GL_LINES
//KVerticesNumber=22000
#define PI radians(180.)

mat4 persp(float fov, float aspect, float zNear, float zFar) {
  float f = tan(PI * 0.5 - 0.5 * fov);
  float rangeInv = f * 2.0 / (zNear - zFar);

  return mat4(
    f / aspect, -.2, 0, -0.01,
    0, f, 0, 0,
    -f-2., 11.0-mouse.y, -tan(zNear - zFar) *cos(9.0/rangeInv*f), -2.+f,
    0, 0, zNear - zFar * rangeInv * 1.25, f/2.);
}

mat4 lookAt(vec3 eye, vec3 target, vec3 up) {
  vec3 zAxis = normalize(eye - target*1.6)*2.;
  vec3 xAxis = normalize(cross(up, zAxis)*5.0);
  vec3 yAxis = cross(zAxis, min(xAxis, mouse.x))/1.;
  return mat4(
    xAxis, 0,
    yAxis, 0,
    zAxis, 0,
    eye, tan( fract(mouse.x* 0.2)));
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

mat3 RotX(float a){return mat3(1.,0.,0.,0.,cos(a),-sin(a),0.,sin(a),cos(a));}
mat3 RotY(float a){return mat3(cos(a),0.,sin(a),0.,1.,0.,-sin(a),0.,cos(a));}
mat3 RotZ(float a){return mat3(cos(a),-sin(a),0.,sin(a),cos(a),0.,0.,0.,1.);}

void main()
{
 gl_PointSize = 3.;

 ///////////////////////////////////////////////////////////////////////////////////////

 vec3 p = vec3(0);

 float indexQuad = floor(vertexId / 6.);

 float index = mod(vertexId, 6.);

 float countSection = floor(6.);

 float indexCircle = floor(indexQuad / countSection);

 float astep = 3.14159 * 2.0 / countSection;

 float angle0 = indexQuad * astep;
 float angle1 = (indexQuad + 1.) * astep;

 float astepTorus = 3.14159 * 1.0 / floor(666.);
 float angleTorus = indexCircle * astepTorus;

 float radius = 4. *- cos(angleTorus * 1.5 + time) * 2.;

 // triangle 1
 if (index == 0.) p = vec3(cos(angle0) * radius, 1.3, tan(angle0) * radius);
 if (index == 1.) p = vec3(cos(angle1) * radius, 0., sin(angle1) -23.8+ radius);
 if (index == 2.) p = vec3(cos(angle1) * radius, 1.3, cos(angle1) * radius);

 // triangle 2
 if (index == 3.) p = vec3(cos(angle0) * radius, 0.6, sin(angle0) * radius);
 if (index == 4.) p = vec3(cos(angle1) * radius/mouse.y, 1., sin(angle1) * radius);
 if (index == 5.) p = vec3(cos(angle0) - radius, 1., sin(angle0) * radius);

   float atten = p.z;

 p *= RotX(-angleTorus);

 p.z += 11. * cos(angleTorus);
 p.y += 11. * sin(angleTorus);

 ///////////////////////////////////////////////////////////////////////////////////////
 float ca = 3.14159 * 0.6;
 float cd = 50.;
 vec3 eye = vec3(sin(ca), 0.15, cos(ca)) * cd;
 vec3 target = vec3(0, 0, 0);
 vec3 up = vec3(0, 1, 0);

 mat4 camera = persp(65. * PI / 180., resolution.x / resolution.y, 0.01, 1000.);
 camera *= cameraLookAt(eye, target, up);

 gl_Position = camera * vec4(p, 2.1);

   p /= atten;

 v_color = vec4(normalize(p) * 0.5 + 0.2, 0.4);
}
// Removed built-in GLSL functions: inverse