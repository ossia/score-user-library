/*{
  "DESCRIPTION": "crazymusicbox",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/KFvg6n392t9qpC7HD)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 3333,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 85,
    "ORIGINAL_DATE": {
      "$date": 1612352541821
    }
  }
}*/

/*

___________________1111111111111__________________
______________1¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶1_____________
___________1¶¶¶¶¶¶111111111111111¶¶¶¶¶¶1__________
_________1¶¶¶11111111111111111111111¶1¶¶¶1________
_______1¶¶¶¶1111111111111111111111111111¶¶¶1______
______1¶¶1¶1111111111¶¶¶¶¶¶¶¶1111111111111¶¶1_____
_____¶¶¶11111111¶¶¶¶¶¶¶¶1_¶¶¶¶¶¶¶¶111111111¶¶¶____
____¶¶¶1111111¶¶¶¶¶¶¶¶1_____¶¶¶¶¶¶¶¶11111111¶¶¶___
___1¶¶111111¶¶¶¶¶¶¶¶1_________¶¶¶¶¶¶¶¶1111111¶¶1__
___¶¶11111¶¶¶¶¶¶¶¶1____________1¶¶¶¶¶¶¶¶111111¶¶1_
__¶¶11111¶¶¶¶¶¶¶¶¶¶¶¶¶_____¶¶¶¶¶1¶¶¶¶¶¶¶¶111111¶¶_
__¶¶1111¶¶¶¶¶¶¶¶_____¶¶¶¶_¶¶_____1¶¶¶¶¶¶¶¶11111¶¶_
__¶¶1111¶¶¶¶¶¶¶1________¶¶________¶¶¶¶¶¶1¶¶1111¶¶_
__¶1111¶¶¶¶¶¶¶¶_______¶¶_¶_¶¶______¶¶¶¶¶¶1¶11111¶_
__¶¶111¶1¶¶¶¶¶¶_______¶¶_¶_¶¶______¶¶¶¶¶¶1¶11111¶_
__¶1111¶¶1¶¶¶¶¶¶________¶¶¶_______1¶¶¶¶¶11¶11111¶_
__¶¶111¶¶1¶¶¶¶¶¶1_____¶¶¶_¶¶______¶¶¶¶¶¶1¶¶1111¶¶_
__1¶¶111¶11¶¶¶¶¶¶¶¶¶¶¶¶_____¶¶¶¶_¶¶¶¶¶¶11¶1111¶¶1_
___¶¶¶11¶¶11¶¶¶¶¶¶¶1___________¶¶¶¶¶¶¶11¶¶111¶¶¶__
___1¶¶111¶¶111¶¶¶¶¶¶¶________1¶¶¶¶¶¶111¶¶1111¶¶1__
____1¶¶1111¶¶111¶¶¶¶¶¶¶1___¶¶¶¶¶¶¶111¶¶¶1111¶¶1___
_____1¶¶¶111¶¶¶11111¶¶¶¶¶¶¶¶¶¶11111¶¶¶11111¶¶1____
______1¶¶¶1111¶¶¶¶¶1111¶¶¶11111¶¶¶¶¶11111¶¶¶1_____
________1¶¶111111¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶1111111¶¶1_______
__________¶¶1111111111¶¶¶¶1111111111111¶1_________
__________¶¶¶11111111¶¶11¶¶11111111111¶¶¶_________
________1¶¶11¶1¶¶111111111¶111111¶¶¶¶¶11¶¶________
_______1¶¶111111¶¶¶¶¶1¶1¶¶¶¶¶¶¶¶¶¶1111111¶¶_______
_______¶¶¶11111111111111¶¶11¶1111111111111¶¶______
______1¶1111¶11111111111¶¶11111111111111111¶1_____
______¶¶111¶111111111111¶¶1111111111111¶111¶¶_____
_____1¶111¶¶111111111111¶¶1111111111111¶1111¶1____
_____¶¶¶¶¶¶¶111111111111¶¶1111111111111¶¶¶¶¶¶¶____
____¶¶¶¶¶¶¶¶¶11111111111¶¶111111111111¶¶¶¶¶¶¶¶¶___
____¶¶¶¶¶¶¶¶¶11111111111¶¶111111111111¶¶¶¶¶¶¶¶¶___
____1¶¶¶¶¶¶1111111111111¶¶11111111111111¶¶¶¶¶¶1___
______1111¶1111111111111¶¶11111111111111¶1111_____
__________¶¶¶11111111111¶¶111111111111¶¶¶_________
__________¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶_________
________1¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶1¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶1_______

*/

// based & influenced by this https://github.com/KessonDalef/Shaders/blob/master/Vertex/spherepointcloud.vert

/*{
  "pixelRatio": 1,
  "vertexCount": 80000,
  "vertexMode": "POINTS",
}*/

#define DOTS_PER 80000.
#define PI radians(180.)
#define NUM_SEGMENTS 4.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.6

precision mediump float;
/*
attribute float vertexId;
uniform float vertexCount;
uniform float time;
uniform vec2 resolution;

*/

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// 2D Random
float random (in vec2 st) {
    return fract(sin(dot(st.xy,
        vec2(12.9898,78.233)))
        * 43758.5453123);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Cubic Hermine Curve. Same as SmoothStep()
    vec2 u = f*f*(3.-2.0*f);
    u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
        (c - a)* u.y * (1.0 - u.x) +
        (d - b) * u.x * u.y;
}

mat4 rotateX(float angle) {
  float s = sin(angle);
  float c = cos(angle);

  return mat4(
    1, 0, 0, 0,
    0, c, s, 0,
    0, -s, c, 0,
    0, 0, 0, 1);
}

mat4 rotateY(float angle) {
    float s = sin(angle);
    float c = cos(angle);

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 1);
}

mat4 rotateZ(float angle) {
    float s = sin(angle);
    float c = cos(angle);

    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1);
}

float easeInOutSine(float x)
{
  return -(cos(PI * x) - 1.) * 0.5;
}

vec4 Slerp(vec4 p0, vec4 p1, float t)
{
  float dotp = dot(normalize(p0), normalize(p1));
  if ((dotp > 0.9999) || (dotp<-0.9999))
  {
    if (t<=0.5)
      return p0;
    return p1;
  }
  float theta = acos(dotp * PI/180.0);
  vec4 P = (
    (
      p0*sin((1.-t)*theta) + p1*sin(t*theta)
    ) / sin(theta)
  );
  P.w = 1.;
  return P;
}

vec3 posf2(float t, float i, float snd)
{

 return vec3(
      cos(t*.4+i*1.53) +
      sin(t*4.84+i*.6)
      //noise(vec2(t*.5*snd, i))
      ,
      cos(t*1.4+i*1.353-2.1) +
      sin(t*4.84+i*.476-2.1)
      //noise(vec2(t, i))
      ,
      sin(t*1.84+i*.36+2.1)// +
 )*.1;
}

vec3 posf0(float t, float fsndweight, float snd) {
  //return posf2(t,-1.)*0.9;
  return posf2(t,-1.,snd)*fsndweight;
}

vec3 posf(float t, float i, float fsndweight, float snd)
{
  //float fsndweightf = mix(4.4, 4.49, pow(fsndweight, 2.0));
  return posf2(t*.045,i,snd) + posf0(t,fsndweight,snd);
}

vec3 push(float t, float i, vec3 ofs, float lerpEnd, float lenghtweight, float snd) {
  //vec3 pos = posf(t,i,.49)+ofs;
  vec3 pos = posf(t,i, mix(.45, 4.5, pow(snd, 1.0)), snd) + ofs;

  vec3 posf = fract(pos+.25)-.5;

  float l = length(posf)*lenghtweight; //1.5
  //return (- posf + posf/l)*(1.-smoothstep(lerpEnd,3.,l));
  //return (posf/l)*(1.-smoothstep(lerpEnd,2.9,l));
  return (posf/l)*(1.-smoothstep(lerpEnd,1.,l));
}

float m1p1(float v) {
  return v * 2. - 1.;
}

// YUV to RGB matrix
mat3 yuv2rgb = mat3(1.0, 0.0, 1.13983,
        1.0, -0.39465, -0.58060,
        1.0, 2.03211, 0.0);

// RGB to YUV matrix
mat3 rgb2yuv = mat3(0.2126, 0.7152, 0.0722,
        -0.09991, -0.33609, 0.43600,
        0.615, -0.5586, -0.05639);

#define OCTAVES 12
float fbm (in vec2 st) {
    // Initial values
    float value = 0.0;
    float amplitude = .5;
    float frequency = 0.;
    //
    // Loop of octaves
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * noise(st);
        st *= 2.;
        amplitude *= .5;
    }
    return value;
}

float fbm2 ( in vec2 _st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5),
        -sin(0.5), cos(0.50));
    for (int i = 0; i < OCTAVES; ++i) {
        v += a * noise(_st);
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void main(void)
{

  float t = time*.6;
  float i = vertexId+sin(vertexId)*100.;

  float v = vertexId / vertexCount;
  float invV = 1.0 - v;
  float thingId = floor(vertexId / DOTS_PER);
  float numThings = floor(vertexCount / DOTS_PER);
  float thingV = thingId / numThings;

  float snd = texture(sound, vec2(thingV * 0.5 + 0.01, mod(thingV * 4., 4.) * 6. / 24.)).r*mix(.5, .9, .8);

  vec3 pos = posf(t,i, mix(1.45, 4.5, pow(snd, 1.)), snd);

  vec3 ofs = vec3(0);

  for (float f = -10.; f < 0.; f++) {
   //ofs += push(t+f*.03,i,ofs,2.-exp(-f*.1),mix(1.45, 1.5, pow(snd, 1.)),snd);
      ofs += push(t+f*.03,i,ofs,2.-exp(-f*.1),mix(1.45, 1.5, pow(snd, 1.)),snd);
  }
  ofs += push(t,i,ofs,.999,mix(1.45, 1.5, pow(snd, 2.)),snd);

  //pos -= posf0(t);
  pos -= posf0(t,.49, snd);

  pos += ofs;

  vec3 oscillationV = posf0(t*.1,0.25, 10.001);

  oscillationV = vec3(
    oscillationV.x,
    dot(normalize( cross(pos,vec3(1.0,0.0,0.0)) ),oscillationV),
    dot(pos,oscillationV)
  );

  float offset = .5 + .5*sin( 1.0 + 6.0*pow(.5-.5*oscillationV.x,1.) );
  float dist = length( oscillationV*vec3(5.,.0,.0) ) - .80 - offset;

  dist += 8.*sin(1.*oscillationV.z);
  dist += sin(10.0*oscillationV.x) * sin(500.*oscillationV.y) * sin(10.*oscillationV.z) * clamp(2.0*oscillationV.y+0.5,0.0,1.0);
  //dist *= clamp(2.0*oscillationV.y+0.5,0.0,1.0);

  //vec4 sphericalInt = Slerp(vec4(pos, 1.), vec4(vec3(ofs), 1.), time*pow(snd, 2.));

  pos.yz *= mat2(dist*0.8,dist*.6,-dist*.6,dist*0.8);
  pos.xz *= mat2(dist*0.8,dist*.6,-dist*.6,dist*0.8);

  //pos.yz *= mat2(.8,.6,-.6,.8);
  //pos.xz *= mat2(.8,.6,-.6,.8);

  //sphericalInt.yz *= mat2(.8,.6,-.6,.8);
  //sphericalInt.xz *= mat2(.8,.6,-.6,.8);

  pos.x *= resolution.y/resolution.x;
  pos.z *= resolution.y/resolution.x;

  mat4 rotation = rotateY(time*0.15);
  vec4 rot = vec4(pos.xyz, 1.0) * rotation;

  pos.z += .9;

  //rot *= .95;
  rot *= .5;

  gl_Position = vec4(rot.xyz, 0.55);
  gl_PointSize = .3;

  float hue = 1.6 + v;// + v * time * 0.;
  hue = mix(hue, 50., mod(floor(t * 4.0), 1.4));
  hue = mix(hue, 0.5, step(0.95, snd*0.95));

  float clipZ = m1p1(gl_Position.z / gl_Position.w);
  float invClipZ = 1. - clipZ;
  float val = invClipZ * 150.;

  //v_color = vec4(hsv2rgb(vec3(hue*2., hue*22., val)),mix(1., 2.5, pow(snd, 4.)));
  v_color = vec4(yuv2rgb * vec3(0.5, pos.x, pos.y),mix(1., 2.5, pow(snd, 4.)));
  v_color = vec4(
    v_color.rbg * v_color.g,
    v_color.a
  );
  v_color += fbm(pos.xy*50.0);

  //v_color += vec4(.7, 0.6, 1.0, 0.6);
}
