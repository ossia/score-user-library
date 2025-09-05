/*{
  "DESCRIPTION": "height-in-shader",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/7DebjyLHPNMjyBzn3)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 16384,
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
    "ORIGINAL_VIEWS": 324,
    "ORIGINAL_DATE": {
      "$date": 1541082601471
    }
  }
}*/


vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

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

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float u = mod(vertexId, across) / across; // 0 <-> 1 across line
  float v = floor(vertexId / across) / down; // 0 <-> 1 by line
  float invV = 1.0 - v;

  // Only use the left most 1/20th of the sound texture
  float historyX = u * 0.05;
  // Match each line to a specific row in the sound texture
  float historyV = v;
  float snd = texture(sound, vec2(historyX, historyV)).r;

  float x = u * 2.0 - 1.0;
  float y = v * 2.0 - 1.0;
  vec2 xy = vec2(x, y);

  float sp = time * .1;
  mat4 pmat = persp(radians(60.0), resolution.x / resolution.y, .1, 4000.0);
  vec3 eye = vec3(mouse.x, mouse.y, 1);
  vec3 target = vec3(0);
  vec3 up = vec3(0,1,0);

  mat4 cmat = lookAt(eye, target, up);
  mat4 vmat = inverse(cmat);

  gl_Position = pmat * vmat * vec4(xy * 0.5, pow(snd, 5.) * .2, 1);
  gl_PointSize = 5.0;

  float hue = u * .1 + time * 0.02;
  float sat = .5;
  float val = mix(0.5, 1., snd);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}
// Removed built-in GLSL functions: inverse