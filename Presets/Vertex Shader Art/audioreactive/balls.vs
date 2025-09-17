/*{
  "DESCRIPTION": "balls",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/ruRxM7a7ngW6o8SPY)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 38300,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 584,
    "ORIGINAL_LIKES": 7,
    "ORIGINAL_DATE": {
      "$date": 1447595070568
    }
  }
}*/

#define PI 3.14159

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void sphere(float v, float time, out vec3 pos, out vec3 color) {
  float vertex = mod(v, 6.);
  v = (v-vertex)/6.;
  float a1 = mod(v, 8.);
  v = (v-a1)/8.;
  float a2 = v-8.;

  float a1n = (a1+.5)/8.*2.*PI;
  float a2n = (a2+.5)/8.*2.*PI;

  a1 += mod(vertex,2.);
  a2 += vertex==2.||vertex>=4.?1.:0.;

  a1 = a1/8.*2.*PI;
  a2 = a2/8.*2.*PI;

  pos = vec3(cos(a1)*cos(a2),sin(a2),sin(a1)*cos(a2));
  vec3 norm = vec3(cos(a1n)*cos(a2n),sin(a2n),sin(a1n)*cos(a2n));

  pos.xz *= mat2(cos(time),sin(time),-sin(time),cos(time));
  pos.yz *= mat2(cos(time),sin(time),-sin(time),cos(time));
  norm.xz *= mat2(cos(time),sin(time),-sin(time),cos(time));
  norm.yz *= mat2(cos(time),sin(time),-sin(time),cos(time));

  color = vec3(1,1,1) * (dot(normalize(vec3(0.3, 0.5, 0.3)), norm) * 0.5 + 0.5);
}

void main() {
  vec3 pos;
  vec3 light;

  float count = floor(vertexId / 384.0);
  float col = mod(count, 10.);
  float row = floor(count / 10.);
  float u = col / 9.;
  float v = row / 9.;
  float vs = v * 2. - 1.;
  float us = u * 2. - 1.;
  float s =
    texture(sound, vec2(0.05, abs(us) * 0.05)).r +
    texture(sound, vec2(0.10, abs(us) * 0.05)).r +
    texture(sound, vec2(0.15, abs(us) * 0.05)).r;
  float s2 =
    texture(sound, vec2(0.025, abs(vs) * 0.05)).r +
    texture(sound, vec2(0.120, abs(vs) * 0.05)).r +
    texture(sound, vec2(0.125, abs(vs) * 0.05)).r;
  sphere(mod(vertexId, 384.0), time + pow(s * 2. - 1.,s), pos, light);

  vec3 p = vec3((col + mod(row, 2.) * 0.5) / 9. * 2. - 1., (row + mod(col, 2.) * 0.0) / 9. * 2. - 1., 0.);
  float a = atan(vs, us);// + time;
  vec3 cs = vec3(1, 1, 1);

  gl_Position = vec4(p * cs + vec3(pos.x*resolution.y/resolution.x,pos.y, -pos.z*.5+.5) * (0.1 + 0.1 * pow(s * 0.7, 2.0)), 1);

  v_color = vec4(vec3(light) * pow(s2 * 0.7, 3.0), 1);
}