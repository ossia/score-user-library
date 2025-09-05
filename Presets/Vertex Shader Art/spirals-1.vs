/*{
  "DESCRIPTION": "spirals",
  "CREDIT": "mohammad (ported from https://www.vertexshaderart.com/art/FEuQEawn8qHXvXTbY)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 38147,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 35,
    "ORIGINAL_DATE": {
      "$date": 1589156850715
    }
  }
}*/

#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define PI radians(180.)

const float FARCLIPPED = 100000. ;
const float NEARCLIPPED = 100.0 ;
float g_cameraFar = 1000.0;

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
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
    return inverse(lookAt(eye, target, up));
}

vec3 spiral(float vidx, float f, float b) {
  float idx = mod(f + vidx * 0.4 + mod(time * 5.0, 20.0) / 20.0 * 100.0, 100.0);
  float t = idx / 100.0;
  float y = 50.0 - 100.0 * t;
  float theta = t * 50.0;
  float r = (50.0 - abs(y))/50.0 * 60.0;
  return vec3(cos(theta) * r, y, sin(theta)*r);
}

void main() {
       mat4 m = persp(radians(60.),
        resolution.x/ resolution.y,
        NEARCLIPPED ,
        FARCLIPPED);
      vec3 target = vec3(-500.0, 0.0, -500.0 ) ;
      vec3 up = vec3(0. ,1. , 0. ) ;
      vec3 camTarget = target ;
      vec3 camPos = vec3(250. ,500. ,800.);
      vec3 camForward = normalize(camTarget - camPos);
      m *= cameraLookAt(camPos , camTarget, normalize(up));

  float spiralIdx = floor(vertexId / 100.0);
  float vIdx = mod(vertexId, 100.0);

  float b = sin(time);
  b = 100.0 / (1.0 + b * b * 20.0);

  vec3 spiralVertex = spiral(vIdx, 2.0, b);
  spiralVertex += vec3(-mod(spiralIdx, 10.0) * 150.0, 0.0, -floor(spiralIdx / 10.0) * 150.0);

  gl_Position = m * vec4(spiralVertex, 1);

  //v_color = mix(vec4(hsv2rgb(vec3(hue, sat, val)), 1), background, v * v);
  v_color = vec4(1, 1, 1, 1);
  gl_PointSize = 2.0;
}
// Removed built-in GLSL functions: inverse