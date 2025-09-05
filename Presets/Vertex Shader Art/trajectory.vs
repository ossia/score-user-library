/*{
  "DESCRIPTION": "trajectory",
  "CREDIT": "tom (ported from https://www.vertexshaderart.com/art/b32w7foxrhZkD9GeR)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 32768,
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
    "ORIGINAL_VIEWS": 155,
    "ORIGINAL_DATE": {
      "$date": 1454793982096
    }
  }
}*/

#define PI 3.14159265

vec4 project(vec3 p) {
  p.x *= resolution.y/resolution.x;
  const float near = .9, far = 3.;
  const float a = -(near+far)/(near-far);
  const float b = 2.*near*far/(near-far);
  return vec4(p.xy, a*p.z + b, p.z);
}

void main () {
  float u = vertexId * (1./256.);
  float v = floor(u);
  u = (u - v) * 2. * PI;
  v *= PI / 128.;

  u += time * .1;

  // 3D polar sphere coords:
  float sin_v = sin(v);
  vec3 n = vec3(cos(u) * sin_v, cos(v), sin(u) * sin_v);
  v_color = vec4(vec3(-n.z*.8), 1.);

  vec4 p = project(n + vec3(0.,0.,2.));

  // Deform in 2d:
  float scale = .1*p.w*mouse.x;
  p.x += cos(n.y*4.)*scale;
  p.y += cos(n.x*8.)*scale;

  gl_Position = p;
  gl_PointSize = 4.;
}