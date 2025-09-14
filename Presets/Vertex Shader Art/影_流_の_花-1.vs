/*{
  "DESCRIPTION": "\u5f71 \u6d41 \u306e \u82b1",
  "CREDIT": "evan_chen (ported from https://www.vertexshaderart.com/art/fNyYuzQ69eREkJCMq)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 6000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    0.8901960784313725,
    0.8431372549019608,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 26,
    "ORIGINAL_DATE": {
      "$date": 1579398666268
    }
  }
}*/

#pragma once
/*

Final View:

https://www.bilibili.com/video/av84117427/

这就是你分手的借口，
🕺🕺🕺如果让你重新来过，
🕺🕺🕺你会不会爱我，
🕺🕺🕺爱情让人拥有快乐，
🕺🕺🕺也会带来折磨，
🕺🕺🕺曾经和你一起走过传说中的爱河，
🕺🕺🕺已经被我泪水淹没，
🕺🕺🕺变成痛苦的爱河这就是你分手的借口，🕺🕺🕺

@31/12/2019
*/
#define PI radians(180.)

mat4 mAspect = mat4
(
  1, 0, 0, 0,
  0, resolution.x / resolution.y, 0, 0,
  0, 0, 1, 0,
  0, 0, 0, 1
);
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
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
    0, 0, 0, 1);
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
// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}
// terrain function from mars shader by reider
// https://www.shadertoy.com/view/XdsGWH
const mat2 mr = mat2 (0.84147, 0.54030,
       0.54030, -0.84147 );
float hash2( in float n )
{
 return fract(sin(n)*43758.5453);
}
float noise(in vec2 x)
{
 vec2 p = floor(x);
 vec2 f = fract(x);

 f = f*f*(3.0-2.0*f);
 float n = p.x + p.y*57.0;

 float res = mix(mix( hash(n+ 0.0), hash(n+ 1.0),f.x),
     mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);
 return res;
}
float fbm( in vec2 p )
{
 float f;
 f = 0.5000*noise( p ); p = mr*p*2.02;
 f += 0.2500*noise( p ); p = mr*p*2.33;
 f += 0.1250*noise( p ); p = mr*p*2.01;
 f += 0.0625*noise( p ); p = mr*p*5.21;

 return f/(0.9375)*smoothstep( 260., 768., p.y ); // flat at beginning
}
float m1p1(float v) {
  return v * 2. - 1.;
}

float inv(float v) {
  return 1. - v;
}

vec3 getQPoint(const float id) {
  float outId = mix(id, 8. - id, step(2.5, id));
  float ux = floor(outId / 6.) + mod(outId, 2.);
  float vy = mod(floor(outId / 2.) + floor(outId / 3.), 2.);
  vec3 pos = vec3(ux, vy, 0);
  return pos;
}

#pragma region FlowerComponent

#define limbVC 1000.
#define MajorVC 1000.
void GenFlower(float offsetX, float offsetX2 ,
        float offsetY,
        inout float In_vertexIndex ,
        out vec3 Pos ,
        out mat4 model)
{
  /*Time&Music Setting*/
    float ux = mod(In_vertexIndex, 1.) ;
    float vy = floor(In_vertexIndex /1. ) ;
    vec4 soundUV = texture(sound, vec2(ux,vy));
   float pPoint= soundUV.r * 0.25;

   float radius = 0. ;
   if(In_vertexIndex > 0. && In_vertexIndex < limbVC )
  {
    float fy = floor(In_vertexIndex / (limbVC ) );
    float xOffset = fract( (In_vertexIndex) / (limbVC * 2.)) * 0.2 ;
 float yOffset = sqrt(xOffset ) ;
    if(soundUV != vec4(0.))
    {
      if(sin( 3.5 * time)> 0.)
        xOffset = sin(yOffset * 100. * pPoint) * 0.025 * pPoint * time * 0.0003;
      else
        xOffset = -sin(yOffset * 100. * pPoint) * 0.025 * pPoint * time * 0.0003;
    }
    Pos = vec3(xOffset + offsetX+ offsetX2,- yOffset + offsetY , 0. );
  }
  In_vertexIndex -= limbVC;
  if(In_vertexIndex > 0. && In_vertexIndex < MajorVC)
  {
    radius = sin(In_vertexIndex * (1.)) * .2 ;
    if(mouse.y > -0.6 && mouse.y < 0.1)
    {
      if(mouse.y > -0.6 && mouse.y < -0.4)
       radius = sin(In_vertexIndex * floor(4. * mouse.y)) * .2 ;
      if(mouse.y > -0.4 && mouse.y < -0.2)
      radius = sin(In_vertexIndex * floor(5.)) * .2 ;
      if(mouse.y > -0.2 && mouse.y < -0.1)
        radius = sin(In_vertexIndex * floor(3. * mouse.y)) * .2 ;
    }
    if(mouse.y > 0.0)
      radius = sin(In_vertexIndex * (5. * pPoint * log(mouse.y))) * .2 ;
    float xPos = radius * sin(In_vertexIndex) ;
    float yPos = radius * cos(In_vertexIndex) ;
    float zPos = 0.1 ;
    Pos = vec3( xPos + offsetX, yPos + offsetY, zPos);

  }
  In_vertexIndex -= MajorVC;
 // model *= trans(vec3(0. , 0. , 0.)) ;

}

#pragma endregion

/* -------------------------------- Display ------------------------------- */

/* -------------------------------- Display ------------------------------- */
#define OffsetX1 -1.
#define OffsetX2 +1.
#define OffsetX3 0.
#define OffsetXX1 -0.04
#define OffsetXX2 +0.04
#define OffsetXX3 0.
#define OffsetY1 0.0
#define OffsetY2 0.0
void main()
{
 /*UniformSetting*/
  mat4 m = persp(radians(45.), resolution.x / resolution.y, 0.1 , 20. );
  vec3 camera = vec3(0. , 0. , 1. ) ;
  vec3 target = vec3(0.);
  vec3 up = vec3(0., 1., 0.);
  m*= cameraLookAt(camera , target , up);
  m*= uniformScale(0.4);

  float vertexIndex = vertexId ;
  vec3 Pos = vec3(0.) ;
  float u = mod(vertexId , 10.);
  float v = floor(vertexId/ 10.) ;

 /*影流の花*/
  GenFlower(OffsetX1, OffsetXX1,
        OffsetY1, vertexIndex , Pos, m);

  GenFlower(OffsetX2, OffsetXX2,
        OffsetY1, vertexIndex , Pos, m);

  GenFlower(OffsetX3, OffsetXX3,
        OffsetY1, vertexIndex , Pos, m);
 /*Apply*/
  gl_Position = m*vec4(Pos, 1);
  gl_PointSize = 2.;
  v_color = vec4(vec3(0.), 1.);

}


// Removed built-in GLSL functions: transpose, inverse