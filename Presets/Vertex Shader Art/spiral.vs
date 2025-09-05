/*{
  "DESCRIPTION": "spiral",
  "CREDIT": "sap (ported from https://www.vertexshaderart.com/art/9tQdLKqdczvbu3Pp5)",
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
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 153,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1448575532536
    }
  }
}*/

#define TAU 6.28
#define PI 3.145191

#define MOD3 vec3(.1031,.11369,.13787)
#define MOD4 vec4(.1031,.11369,.13787, .09987)
float hash11(float p)
{
 vec3 p3 = fract(vec3(p) * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

float hash12(vec2 p)
{
 vec3 p3 = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

float SmoothNoise(in vec2 o)
{
 vec2 p = floor(o);
 vec2 f = fract(o);

 float n = p.x + p.y*57.0;

 float a = hash11(n+ 0.0);
 float b = hash11(n+ 1.0);
 float c = hash11(n+ 57.0);
 float d = hash11(n+ 58.0);

 vec2 f2 = f * f;
 vec2 f3 = f2 * f;

 vec2 t = 3.0 * f2 - 2.0 * f3;

 float u = t.x;
 float v = t.y;

 float res = a + (b-a)*u +(c-a)*v + (a-b+d-c)*u*v;

    return res;
}

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float n = vertexId / vertexCount;
  float z = vertexId / 2000.;

  float m = pow (n, 1.12);
  float k = 1. - m;

  vec2 p;

  p = vec2(k * z * 0.7 * cos(0.7 * PI + time) * cos(time), k * z * 0.3 * sin(time));

  vec2 d = 0.3*vec2(z * cos(vertexId * TAU * 0.0051), z * sin(vertexId * TAU * 0.0051));
  p += d + d * 0.1 * SmoothNoise(d + vec2(time, time) + hash12(d) * 0.4);

  p.xy *= resolution.yy / resolution.xy;

  gl_Position = vec4(p, 0., 1.);

  vec3 c = hsv2rgb(vec3(10. / 360. * time,mix(.6, 1., m), m));

  v_color = vec4(c,1);
}