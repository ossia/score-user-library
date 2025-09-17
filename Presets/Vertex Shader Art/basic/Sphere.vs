/*{
  "DESCRIPTION": "Sphere",
  "CREDIT": "rmccampbell7 (ported from https://www.vertexshaderart.com/art/rprQ8uGr5rvgeTCMd)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 20000,
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
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1662538832515
    }
  }
}*/

const float TAU = radians(360.);
const float NLON = 20.;
const float NLAT = 10.;
const float NPOINTS = NLON*(NLAT+1.);

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 rotx(vec3 v, float theta) {
  float c = cos(theta), s = sin(theta);
  return vec3(v.x, c*v.y-s*v.z, s*v.y+c*v.z);
}

vec3 roty(vec3 v, float theta) {
  float c = cos(theta), s = sin(theta);
  return vec3(c*v.x+s*v.z, v.y, -s*v.x+c*v.z);
}

void main() {
  float id = mod(vertexId, NPOINTS);
  float u = fract(id / NLON);
  float v = floor(id / NLON) / NLAT;
  float theta = TAU*u;
  float phi = .5*TAU*v;
  float x = cos(theta)*sin(phi);
  float z = sin(theta)*sin(phi);
  float y = -cos(phi);

  vec3 pos = roty(rotx(vec3(x, y, z), .95*TAU), time) * .8;
  float aspect = resolution.y / resolution.x;
  gl_Position = vec4(pos.x*aspect, pos.y, pos.z, 1);
  gl_PointSize = 10.;

  v_color = vec4(hsv2rgb(vec3(fract(u+v), 1, 1)), 1);
}
