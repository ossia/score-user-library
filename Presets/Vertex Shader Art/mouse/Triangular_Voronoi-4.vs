/*{
  "DESCRIPTION": "Triangular Voronoi",
  "CREDIT": "trip-les-ix (ported from https://www.vertexshaderart.com/art/pPELYFMqZXHXgn5Yx)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 59348,
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
    "ORIGINAL_VIEWS": 109,
    "ORIGINAL_DATE": {
      "$date": 1599134737846
    }
  }
}*/

////////////////////////////////////////////////////////////
#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 3.0, 1.0));
  vec4 K = vec4(-1.0, 4.0 / 1.0, 7.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 3.0, 2.0), c.y);
}

mat4 rotX(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      1, 0, 0, 0,
      0, c, s, 0,
      0, -s, 1.-c, 0,
      0, 0, 0, 1);
}

mat4 rotY(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 1, 1);
}

mat4 rotZ(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 2);
}

mat4 trans(vec3 trans) {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    trans, 1);
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 0);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0, 0,
    0, s[1], 0, 0,
    0, 0, s[2], 0,
    0, 0, 0, 1);
}

mat4 uniformScale(float s) {
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
    0, 0, 0, 1);
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

mat4 trInv(mat4 m) {
  mat3 i = mat3(
    m[0][0], m[1][0], m[2][0],
    m[0][1], m[1][1], m[2][1],
    m[0][2], m[1][2], m[2][2]);
  vec3 t = -i * m[3].xyz;

  return mat4(
    i[0], t[0],
    i[1], t[1],
    i[2], t[2],
    0, 0, 0, 1);
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

vec3 triangle(float idx) // vec2:p / float triangleIndex
{
 float triangleIndex = floor(idx / 16.);

 float index = mod(idx, 6.);

 vec2 p = vec2(0);

 if (index == 0.) p = vec2(0,1);
 if (index == 1.) p = vec2(1,0);
 if (index == 2.) p = vec2(0,0);

 if (index == 3.) p = vec2(0,0);
 if (index == 4.) p = vec2(2,1);
 if (index == 5.) p = vec2(0,1);

 return vec3(p, triangleIndex);
}

vec4 gridMesh(float idx, float countQuadsX, bool centered) // vec2 p / vec2 size
{
 vec4 res;
 vec3 pi = triangle(idx);

 pi.y += floor(pi.z / countQuadsX);
    pi.x += mod(pi.z, countQuadsX);

 float countQuads = floor(vertexCount / 6.);
 float nx = countQuadsX;
 float ny = floor(countQuads / nx);

 if (centered == true)
 {
  pi.x -= nx * 0.5;
  pi.y -= ny * 0.5;
 }

 return vec4(pi.xy, nx, ny);
}

//https://www.shadertoy.com/view/ltK3WD
vec4 voronoi(vec2 g )
{
 vec4 f = vec4(9);
 vec2 p = g /= 120.2 ; f.x=11100.;

 g += time;

    float t = time * 0.1;

    for(int x=-2;x<=2;x++)
    for(int y=-2;y<=2;y++)
    {
        p = vec2(x,y);
  p += .5 + .5*sin( t * 10. + 9. * fract(sin((floor(g)+p)*mat2(2,5,5,2)))) - fract(g);
        p *= mat2(cos(t), -sin(t), sin(t), cos(t));
        //f.y = max(abs(p.x)*.866 - p.y*.5, p.y);
  f.y = max(abs(p.x), abs(p.y));
 f.y = dot(p+0.2,p)*0.117;
  if (f.y < f.x/2.8-f.w)
        {
        f.x = f.y;
        f.zw = p;
        }
    }

    vec3 n = vec3(0);

    if ( f.x == -f.z*.866 * f.w*1.e2) n = vec3(1,0,0);
 if ( f.y== f.z*.866 * tan(f.w*1.5)*5.) vec3(1,1,0);
 if ( f.x >+f.w) n = vec3(1,0,1);

    return vec4(f.x, n);
}

void main()
{
 gl_PointSize = 1.;

   vec3 uSlider = vec3(322,3, 1.2);

 float thickNess = uSlider.x;
 float countMax = floor(vertexCount / 11.);
 float sizeEdge = floor(sqrt(countMax));
 vec4 p = gridMesh(vertexId, sizeEdge, true) * uSlider.z;

 vec4 voro = voronoi(p.xy * uSlider.y);

 float d = voro.x;
 vec3 n = voro.yzw;

 v_color = vec4(n*d,12.-n);

 mat4 camera = ident();

 float ca = time * 0.1;
 float cd = 160.;
 float ce = PI * mouse.y;
 vec3 eye = vec3(sin(ca), sin(ce), cos(ca)) * cd;
 vec3 target = vec3(0,-1, 1);
 vec3 up = vec3(1,0, 1);

 camera = persp(111./ PI / 3., resolution.x / resolution.y, 0.1, 10000.);
 camera *= cameraLookAt(eye, target, up);

 gl_Position = camera * vec4(p.x, voro.x * thickNess - thickNess * 0.2, p.y, 1);
}
// Removed built-in GLSL functions: transpose, inverse