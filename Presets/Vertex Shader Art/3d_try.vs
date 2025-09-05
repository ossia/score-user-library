/*{
  "DESCRIPTION": "3d try",
  "CREDIT": "ersh (ported from https://www.vertexshaderart.com/art/rZXHyphbAzHHHzkAc)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 20,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1689307185308
    }
  }
}*/

#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float point = vertexId / vertexCount;
  float angle = point * PI * 2.0;
  float radius = 0.8;
  float t = time * 0.5;
  float c = cos(angle + t) * radius;
  float s = sin(angle + t) * radius;

  //vec2 aspect = vec2(1, resolution.x / resolution.y);
  //float x = c, y = s, z = 1.1, sz = 1./z;
  float fov = 1. + (clamp(mouse.x, -1., 1.) + 1.); // 1.4;
  float x = c, y = s * mouse.y * -0.3, z = (fov + 1.) + s, sz = 1./z;
  float fovxy = fov;
  gl_Position = vec4(vec2(x, y)*fovxy, -sz, z);
  gl_PointSize = resolution.x/15.*sz;

  float hue = (time * 0.01 + point * 1.001);
  float accent = clamp(1./(z-fov), 0., 1.);
  v_color = vec4(hsv2rgb(vec3(hue, accent, accent)), 1);
}