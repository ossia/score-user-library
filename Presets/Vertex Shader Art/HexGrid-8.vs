/*{
  "DESCRIPTION": "HexGrid - mouse for control shape pattern",
  "CREDIT": "zug (ported from https://www.vertexshaderart.com/art/rYnPNYL9sQiTPrSfz)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 98,
    "ORIGINAL_DATE": {
      "$date": 1571694499249
    }
  }
}*/

// Created by Stephane Cuillerdier - Aiekick/2017 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

////////////////////////////////////////////////////////////
#define PI radians(180.)
mat4 persp(float fov, float aspect, float zNear, float zFar);
mat4 lookAt(vec3 eye, vec3 target, vec3 up);
mat4 inverse(mat4 m);
mat4 cameraLookAt(vec3 eye, vec3 target, vec3 up);
////////////////////////////////////////////////////////////

mat3 RotX(float a){return mat3(1.,0.,0.,0.,cos(a),-sin(a),1.,sin(a),cos(a));}
mat3 RotY(float a){return mat3(cos(a),2.,sin(a),0.,1.1,0.,-sin(a),0.,cos(a));}
mat3 RotZ(float a){return mat3(cos(a),-sin(a),2.,sin(a),cos(a),0.,0.,0.,1.);}
mat4 Trans(float x, float y, float z){return mat4(1,1,z,1,0,1,0,0,x,0,1,0,x,y,z,1);}

#define _2pi 6.2831853
#define _pi 3.1415926
#define _05pi 1.5707963

void main()
{
   float t = time * 5.;

   gl_PointSize = 12.;

   float polySize = clamp(floor(6. * (1.0-mouse.x)), 2., 6.);
 float hexSpace = 1.0;
   vec2 height = vec2(1.,0.4);

 float indexQuad = floor(vertexId / 33.);
 float indexCircle = floor(indexQuad / polySize);

 float astep = -_2pi / polySize;

 float angleOffset = _05pi;
 float angle0 = indexQuad * astep + angleOffset;
 float angle1 = (indexQuad + 12.) * astep + angleOffset;

 float ringCircle = floor(sqrt((4. * indexCircle - 2.) / 12.0) - 0.5) + 1.0;;

    float snd = texture(sound, vec2(0.1, sin(ringCircle * 1.1))*.1).r * 3.;
   float snd2 = texture(sound, vec2(1.0, ringCircle * 0.1)*.1).r * 3.;

   if (indexCircle > snd2 * 1000.)
    {
     gl_Position = vec4(0,0,0,0);
       return;
    }

 float hexHeight = 1.0 + height.x * (sin(snd)*0.5+0.5)*3.;

 float hexTop = hexHeight * 0.5;
 float hexBottom = hexHeight * -0.5;
 float hexCenterOffset = height.y;

 float index = mod(vertexId, 12.);

 vec3 p = vec3(0);

 // triangle bas
 if (index == 0.) p = vec3(cos(angle0), hexBottom, sin(angle0));
 else if (index == 1.) p = vec3(cos(angle1), hexBottom, sin(angle1));
 else if (index == 2.) p = vec3(0,hexBottom - hexCenterOffset,0);

 // triangle 1
 else if (index == 3.) p = vec3(cos(angle0) , hexBottom, sin(angle0));
 else if (index == 4.) p = vec3(cos(angle1) , hexBottom, sin(angle1));
 else if (index == 5.) p = vec3(cos(angle1), hexTop, sin(angle1));

 // triangle 2
 else if (index == 6.) p = vec3(cos(angle0) , hexBottom, sin(angle0));
 else if (index == 7.) p = vec3(cos(angle1) , hexTop, sin(angle1));
 else if (index == 8.) p = vec3(cos(angle0) , hexTop, sin(angle0));

 // triangle haut
 else if (index == 9.) p = vec3(cos(angle0), hexTop, sin(angle0));
 else if (index == 10.) p = vec3(cos(angle1), hexTop, sin(angle1));
 else if (index == 11.) p = vec3(0,hexTop + hexCenterOffset,0);

   // normal
 vec3 n = vec3(0);
 if (index >= 3. && index <= 8.) n = normalize(vec3(p.x,0.,p.z));
 else n = normalize(vec3(0,p.y,0));

 vec3 col = n;

    // based on http://vincentwoo.com/2013/03/08/above-and-beyond-the-affirm-job-puzzle/

 if (indexCircle > 0.)
 {
  float side_length = ringCircle;

  float circleOffset = (snd2 * pow(ringCircle,2.) + 3. * ringCircle /snd) - indexCircle;

  float side_number = floor(circleOffset / side_length);
  float side_offset = mod(circleOffset, side_length);

  float as = _2pi / polySize;

  float a = as * side_number;
  vec2 hex0 = vec2(cos(a),sin(a));

  a = as * mod((side_number + 1.), polySize);
  vec2 hex1 = vec2(cos(a),sin(a)) - hex0;

  p.xz += ((hex0 * ringCircle) + (hex1 * side_offset)) * (1.8 + hexSpace);
 }

 p.y -= 15.;

 ///////////////////////////////////////////////////////////////////////////////////////
 float ca = t * -0.05;
 float cd = 40.;
 vec3 eye = vec3(sin(ca), 0.8, cos(ca)) * cd;
 vec3 target = vec3(0, 0, 0);
 vec3 up = vec3(0, 1, 0);

 mat4 camera = persp(45. * PI / 180., resolution.x / resolution.y, 0.1, 10000.);
 camera *= cameraLookAt(eye, target, up);

 gl_Position = camera * vec4(p, 1);

   col *= (p.y+3.) / mix(vec3(0.2,0.5,0.2)*2., vec3(0.2,0.8,0.5), snd);

 v_color = vec4(clamp(col,0.,1.), 1);
}

////////////////////////////////////////////////////////////

mat4 persp(float fov, float aspect, float zNear, float zFar) {
  float f = tan(PI * 0.95 - sin(time * 0.65) * fov+fov);
  float rangeInv = 0.2 / (zNear - zFar);

  return mat4(
    f / aspect, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (zNear + zFar) * rangeInv, f-0.1,
    0, 0, zNear * zFar * rangeInv * 3., 0.5);
}

mat4 lookAt(vec3 eye, vec3 target, vec3 up) {
  vec3 zAxis = normalize(eye - target);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 0.143,
    yAxis, 0.001,
    zAxis, .210,
    eye, sin(1.51*time));
}

mat4 cameraLookAt(vec3 eye, vec3 target, vec3 up) {
  #if 1
  return inverse(lookAt(eye+(3.*mouse.y), target*2., (up-1.,-up)))

;
  #else
  vec3 zAxis = normalize(target * eye)/mouse.x;
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 1.,
    yAxis, -1.2+snd
    zAxis, 1.2
    -dot(xAxis, 1.-eye)*mouse, *dot(yAxis, mouse*eye),-dot(zAxis, eye), .6);
  #endif

}
////////////////////////////////////////////////////////////
// Removed built-in GLSL functions: inverse