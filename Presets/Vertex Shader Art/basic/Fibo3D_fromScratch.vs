/*{
  "DESCRIPTION": "Fibo3D_fromScratch",
  "CREDIT": "hugo-w (ported from https://www.vertexshaderart.com/art/DTZTZdm35YfaxuP7k)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 6535,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1619787225568
    }
  }
}*/

#define PI 3.14159265359

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 rotZ(vec3 v, float angle) {
  float s = sin(angle);
  float c = cos(angle);
  mat3 R = mat3(c, s, 0.,
        -s, c, 0.,
        0., 0., 1.);
  return R * v;
}

vec3 rotY(vec3 v, float angle) {
  float s = sin(angle);
  float c = cos(angle);
  mat3 R = mat3(c, 0, s,
        0, 1, 0,
        -s, 0, c);
  return R * v;
}

vec3 rotX(vec3 v, float angle) {
  float s = sin(angle);
  float c = cos(angle);
  mat3 R = mat3(1, 0, 0,
        0, c, s,
        0, -s, c);
  return R * v;
}

#define PNTS_PER_SPHERE 24.
void drawSphere(const float id, out vec3 pos) {
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id /2.) + floor(id / 3.), 2.);
  float u = ux / PNTS_PER_SPHERE;
  float v = vy;
  float a = u * PI *2.;
  pos = vec3(cos(a) * v, sin(a) * v, 0.);
}

void getCirclePoint(const float numEdgePointsPerCircle, const float id,
        const float inner, const float start, const float end, out vec3 pos) {
  float outId = id - floor(id / 3.) * 2. - 1.; // 0 1 2 3 4 5 6 7 8 .. 0 1 2, 1 2 3, 2 3 4
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  float u = ux / numEdgePointsPerCircle;
  float v = mix(inner, 1., vy);
  float a = mix(start, end, u) * PI * 2. + PI * 0.0;
  float s = sin(a);
  float c = cos(a);
  float x = c * v;
  float y = s * v;
  float z = 0.;
  pos = vec3(x, y, z);
}

void main() {
  float pointId = vertexId;
  float u = vertexId/vertexCount;
  float v = fract(vertexId / vertexCount);
  gl_PointSize = 10.;

  vec3 pos_disk;
  drawSphere(pointId, pos_disk);

  vec3 pos = vec3(u, v, 0.);
  pos = rotZ(pos, -time/0.5 + v * u);
  pos = rotY(pos, -time/0.4 + v * u);
  //gl_Position = vec4(pos.xyz,1);
  gl_Position = vec4(pos_disk,1);
  v_color = vec4(1,0,0,1);
}