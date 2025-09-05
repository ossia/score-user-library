/*{
  "DESCRIPTION": "fractal blue",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/ranzZohyvMMY5qhCs)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Abstract"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 115,
    "ORIGINAL_DATE": {
      "$date": 1601018634655
    }
  }
}*/

//In progress. Based on http://glslsandbox.com/e#44575.1

#define PI radians(270.)

//functions for the shader
float random(in vec2 st) {
 return fract(sin(dot(st, vec2(12.9898, 78.233))) * 43758.545123);
}

float noise(vec2 st) {
 vec2 i = floor(st);
 vec2 f = fract(st);
 vec2 u = f * f * (3.0 - 2.0 * f);
 return mix(mix(random(i + vec2(0.0, 0.0)),
        random(i + vec2(1.0, 0.0)), u.x),
     mix(random(i + vec2(0.0,2.0)),
        random(i + vec2(sin(time-1.5*3.), 1.0)), u.x), u.y);
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
    0, 0, zNear * zFar * rangeInv * 2., 0.);
}

vec2 rotate(vec2 f, float deg)
{
 return vec2(f.x * cos(deg) - f.y * sin(deg), f.x * sin(deg) + f.y * cos(deg));
}

//End functions used for camera

float pattern(vec2 p){p.x -= .866; p.x -= p.y * .005; p = mod(p, 1.); return p.x + p.y < 1.0 ? 0.3: 1.;}

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

  float udnd = u;
  if(u>0.5)
    udnd = 1.-u;

  float snd = texture(sound, vec2(0., udnd)).r;

    //apply fragment logic

 vec2 position = vec2(x,y);

 vec2 uv = vec2(u,v);//position.xy/resolution.xy;
  /*
 vec2 aspect = resolution/min(resolution.x, resolution.y);
 vec2 p = (uv -.5) * aspect;
 vec2 c = p/dot(p,p);
 float centerDistance = distance(c, snd*6.*vec2(0.5)) / 6.0;

 c = rotate(c, max(-10.0, 2.3*sin(time + centerDistance + sin(time + centerDistance))));
   */
    vec2 p = uv;//(-resolution + 2.0*uv.xy)/resolution.y;

  float timeFactor = 10.;

 for(int i = 0; i < 8; i++) {
  p = abs(p)/clamp(dot(p, p), 0.7, 1.0) - vec2(abs(cos(time/timeFactor)), abs(sin(time/timeFactor)));

  p *= mat2(cos(time/timeFactor), sin(time/timeFactor), -sin(time/timeFactor), cos(time/timeFactor));
 }

 vec3 col = mix(vec3(0, 0.1, 0.2), vec3(0.3, 0.5, 1.0), smoothstep(0.0, 1.0, abs(p.x)));
 col = mix(col, vec3(0.3, 0.3, 4), smoothstep(0.9, 1.0, abs(p.y)));
 //gl_FragColor = vec4(col, 1);

 //gl_FragColor = vec4(vec3(pattern), 1.0);

 //gl_FragColor = vec4(pattern(3.*c));

  //camera
  float r = .7;
  float tm = time * 0.05;
  float tm2 = time * 0.05;
  mat4 mat = persp(radians(60.0), resolution.x / resolution.y, 0.1, 10.0);
  vec3 eye = vec3(cos(tm) * r, sin(tm * 0.93) * r, sin(tm) * r);
  vec3 target = vec3(0);
  vec3 up = vec3(0., sin(tm2), cos(tm2));

  mat *= cameraLookAt(eye, target, up);

  gl_PointSize = 2.;//finalDesiredPointSize;

  v_color = vec4(col, 1);
  float depth = (v_color.x*v_color.y*v_color.z)/2.;

  vec4 finalPos = vec4(ux, vy, depth+snd/5., 1.);

  gl_Position = mat*finalPos;
}
// Removed built-in GLSL functions: inverse