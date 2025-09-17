/*{
  "DESCRIPTION": "zheball",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/ijffwwNcMKiZYCxge)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 254,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1585600221010
    }
  }
}*/

#define NUM_POINTS 10000.0
#define PI 3.14159265
#define TWO_PI (PI * 2.0)

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

mat4 rotY(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 1);
}

float getSound(float f, float delay) {
  return texture(sound, vec2(f, delay)).r;
}

vec3 curvePos(float t) {
  float r = (0.6 + sin(t * 31.0 * TWO_PI) * 0.4);
  float phi = sin(t * 43.0 * TWO_PI) * PI;
  float theta = PI * sin(t * 41.0 * PI);
  float x = cos(phi) * cos(theta);
  float y = sin(phi) * cos(theta);
  float z = sin(theta);
  return r * vec3(x, y, z);
}

void main() {
  float t = vertexId / NUM_POINTS;
  vec3 p = curvePos(t);
  float r = sqrt(p.x * p.x + p.y * p.y + p.z * p.z);
  float h = 0.5; //0.5 + 0.5 * sin(r * TWO_PI + time + p.x);
  float s = 1.0; // 0.5 + 0.5 * cos(r * TWO_PI + time + p.x);

  float pulse = sin((time * 0.3 + t * 500.0) * TWO_PI);
  float v = //max(0.5, sin(r * 3.0 * TWO_PI + time * 0.1 + t * 100.0)) - 0.5)
     pow(max(0.0, pulse), 5.0)
     + getSound(0.1, 0.0);

  vec4 vertPos = rotY(time*0.1) * vec4(p, 1.0) + vec4(0.0, 0.0, -3.0, 0.0);
  gl_Position = persp(PI*0.25, resolution.x/resolution.y, 0.1, 100.0) * vertPos;
  v_color = vec4(hsv2rgb(vec3(h, s, v)), 1.0);
}