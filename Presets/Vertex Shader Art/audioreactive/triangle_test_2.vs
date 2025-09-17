/*{
  "DESCRIPTION": "triangle test 2",
  "CREDIT": "trevor (ported from https://www.vertexshaderart.com/art/qSNjoFSsTFZD2TJcg)",
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
    1,
    0.996078431372549,
    0.996078431372549,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 17,
    "ORIGINAL_DATE": {
      "$date": 1502345352707
    }
  }
}*/

#define PI radians(180.)
#define TAU radians(360.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat4 rotX(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      1, 0, 0, 0,
      0, c, s, 0,
      0, -s, c, 0,
      0, 0, 0, 1);
}

mat4 rotY(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 1);
}

mat4 rotZ(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

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

mat4 uniformScale(float s) {
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
    0, 0, 0, 1);
}

void main() {

  float pointsPerLoop = 30.;
  float deg = radians(vertexId / pointsPerLoop * 180. + vertexId * 0.1925 + (time * 20.));
  float sx = mod(vertexId,pointsPerLoop) / pointsPerLoop;
  float sy = floor(vertexId / pointsPerLoop) / floor(vertexCount / pointsPerLoop);
  float snd = texture(sound,vec2(sx*0.125,sy)).r;
  float radius = (2.55 + pow(snd,2.)*3.) * (sin(30.)-sy);

  float x = sin(radius);
  float y = cos(deg) * radius;
  float z = vertexId * 0.125;
  vec3 pos = vec3(x,y,z);

  float aspect = resolution.y / resolution.x;

  mat4 camera = mat4(
    aspect, 0.1, 0., 0.,
        0.2, 1., 0., 0.,
        -0.03, .006, .1, .1,
        0., -3., 0., 3.);

  mat4 rotZee = rotZ(radians(-81.));
  mat4 rotEx = rotX(radians(-5.));
  mat4 rotWhy = rotY(radians(1.));
  mat4 moveIt = trans(vec3(-0.8,1.,-5.));
  mat4 size = uniformScale(10.);

  gl_Position = camera * rotEx * rotZee * rotWhy * moveIt * size * vec4(pos.x-4.5,pos.y-2.,pos.z,1.);
  float hue = (time * 0.01 + radius * 1.001);
  v_color = vec4(hsv2rgb(vec3(hue, 1, 1)), 1);
  //v_color = vec4(1., (vertexId/vertexCount) / 2. + .5, 1., 1. );

}