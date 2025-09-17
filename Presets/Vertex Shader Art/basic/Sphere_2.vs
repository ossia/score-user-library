/*{
  "DESCRIPTION": "Sphere 2",
  "CREDIT": "rmccampbell7 (ported from https://www.vertexshaderart.com/art/LfQCKq93ccXsMC3DD)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1662539825005
    }
  }
}*/

const float EXPLODE = 0.15;
const float SPEED = .5;
const float NLON = 32.;
const float NLAT = 16.;
const float NQUADS = NLON*NLAT;
const float TAU = radians(360.);

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

vec3 rotz(vec3 v, float theta) {
  float c = cos(theta), s = sin(theta);
  return vec3(c*v.x-s*v.y, s*v.x+c*v.y, v.z);
}

struct Vert {
  vec3 pos;
  vec2 uv;
};

Vert getQuadVert(vec2 quadCoord, float quadVertId) {
  vec2 vertOff = (quadVertId == 0. ? vec2(0, 0) :
        quadVertId == 1. ? vec2(1, 0) :
        quadVertId == 2. ? vec2(1, 1) :
        quadVertId == 3. ? vec2(1, 1) :
        quadVertId == 4. ? vec2(0, 1) :
        vec2(0, 0));
  vec2 vertCoord = quadCoord + vertOff;
  vec2 uv = vertCoord / vec2(NLON, NLAT);
  float theta = TAU*uv.x;
  float phi = .5*TAU*uv.y;
  vec3 pos;
  pos.x = sin(theta)*sin(phi);
  pos.y = -cos(phi);
  pos.z = cos(theta)*sin(phi);
  return Vert(pos, uv);
}

vec3 getTriNormal(vec2 quadCoord, float quadVertId) {
  float triVertId0 = floor(quadVertId/3.)*3.;
  vec3 v1 = getQuadVert(quadCoord, triVertId0+0.).pos;
  vec3 v2 = getQuadVert(quadCoord, triVertId0+1.).pos;
  vec3 v3 = getQuadVert(quadCoord, triVertId0+2.).pos;
  return normalize(cross(v2-v1, v3-v1));
}

vec3 getTriCentroid(vec2 quadCoord, float quadVertId) {
  float triVertId0 = floor(quadVertId/3.)*3.;
  vec3 v1 = getQuadVert(quadCoord, triVertId0+0.).pos;
  vec3 v2 = getQuadVert(quadCoord, triVertId0+1.).pos;
  vec3 v3 = getQuadVert(quadCoord, triVertId0+2.).pos;
  return (v1 + v2 + v3) / 3.;
}

void main() {
  float quadId = mod(floor(vertexId / 6.), NQUADS);
  float quadVertId = mod(vertexId, 6.);
  vec2 quadCoord = vec2(mod(quadId, NLON), floor(quadId / NLON));
  Vert v = getQuadVert(quadCoord, quadVertId);
  //vec3 triNorm = getTriNormal(quadCoord, quadVertId);
  vec3 triCentroid = getTriCentroid(quadCoord, quadVertId);
  v.pos += triCentroid*EXPLODE;

  vec3 pos = roty(v.pos, SPEED*time);
  pos = rotx(pos, .08*TAU);
  pos = roty(pos, SPEED*time) * .7;

  float aspect = resolution.x / resolution.y;
  vec2 scale = min(vec2(1./aspect, aspect), 1.);
  gl_Position = vec4(pos.x*scale.x, pos.y*scale.y, -pos.z, 1);
  //gl_PointSize = 4.;

  v_color = vec4(hsv2rgb(vec3(v.uv.x+v.uv.y*.5, 1, 1)), 1);
  //v_color = vec4(triNorm*.5+.5, 1);
  if (pos.z < 0.) v_color *= 0.;
}
