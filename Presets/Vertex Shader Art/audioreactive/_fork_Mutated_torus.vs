/*{
  "DESCRIPTION": "-fork Mutated torus",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/dw7XrmJjH3mBbHx8u)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 16384,
  "PRIMITIVE_MODE": "LINE_LOOP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 119,
    "ORIGINAL_DATE": {
      "$date": 1449397046673
    }
  }
}*/

// nice little fun toy, i like integration with soundcloud
// [commercial]
// also check out http://polycu.be
// [/commercial]

#define W 128
#define H 64
#define PI 3.1415926535

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float fv = floor(vertexId / float(W));
  float fu = vertexId - fv*float(W);
  fu /= float(W);
  fv /= float(H);
  float u = fu*2.*PI;
  float v = fv*1.*PI;
  u += time;

  float sin_u = sin(u), cos_u = cos(u);
  float sin_v = sin(v), cos_v = cos(v);
  float f = texture(sound, vec2(abs(fu-.5)+.1,fv*.1)).x+.05;
  vec3 p = vec3(cos_u*(cos_v*f+1.), sin_u*(cos_v*f+1.), sin_v*f);
  float sin_t = sin(time), cos_t = cos(time);
  p *= mat3(sin_t,0,cos_t, 0,1,0, -sin_t,0,cos_t);
  sin_t = sin(time*.7), cos_t = cos(time*.7);
  p *= mat3(cos_t,sin_t,0, -sin_t,cos_t,0, 0,0,1);
  p.x *= resolution.y/resolution.x;
  p.z += 3.;
  p.xy *= 3./p.z;
  gl_Position = vec4(p.x, p.y, 2., p.z);

  v_color = vec4(hsv2rgb(vec3(fu*3., 1., 1.)), 1);
}
