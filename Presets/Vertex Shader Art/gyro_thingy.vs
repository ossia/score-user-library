/*{
  "DESCRIPTION": "gyro thingy",
  "CREDIT": "megaloler (ported from https://www.vertexshaderart.com/art/8T4bhdbFF8NqLZ5qJ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 13030,
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
    "ORIGINAL_VIEWS": 219,
    "ORIGINAL_DATE": {
      "$date": 1529106668205
    }
  }
}*/

#define PI radians(180.)
#define TAU radians(360.)

vec2 circle(float i) {
  return vec2(cos(i * TAU), sin(i * TAU));
}

mat4 rotZ(float a) {
  return mat4(cos(a), sin(a), 0., 0.,
        -sin(a), cos(a), 0., 0.,
        0., 0., 1., 0.,
        0., 0., 0., 1.);
}

mat4 rotY(float a) {
  return mat4(cos(a), 0., sin(a), 0.,
        0., 1., 0., 0.,
        -sin(a), 0., cos(a), 0.,
        0., 0., 0., 1.);
}

mat4 rotX(float a) {
  return mat4(1., 0., 0., 0.,
        0., cos(a), sin(a), 0.,
        0., -sin(a), cos(a), 0.,
        0., 0., 0., 1.);
}

mat4 translate(vec3 p) {
  return mat4(1., 0., 0., 0.,
        0., 1., 0., 0.,
        0., 0., 1., 0.,
        p.x, p.y, p.z, 1.);
}

mat4 scale(vec3 p) {
  return mat4(p.x, 0., 0., 0.,
        0., p.y, 0., 0.,
        0., 0., p.z, 0.,
        0., 0., 0., 1.);
}

mat4 projection(vec4 pos, float aspect, float near, float far) {
  float range = far - near;
  float p = pos.z - near;
  float z_buf = mix(-1., 1., p / range);
  float z = 1.0 + pos.z;
  return mat4(aspect/z, 0., 0., 0.,
        0., 1./z, 0., 0.,
        0., 0., 0., 0.,
        0., 0., z_buf, 1.);
}

void main() {
  float aspect = resolution.y / resolution.x;
  float shapeCount = 3.;
  float i = vertexId / vertexCount * shapeCount;
  float shape_i = fract(i);
  int shapeId = int(floor(i));
  vec2 circ = circle(shape_i);
  vec4 pos;
  if(shapeId == 0) pos = vec4(circ.x, circ.y, 0., 1.);
  else if(shapeId == 1) pos = vec4(circ.y, 0., circ.x, 1.);
  else if(shapeId == 2) pos = vec4(0., circ.x, circ.y, 1.);
  pos = rotX(time) * rotY(time) * pos;
  pos = translate(vec3(mouse.x/aspect, mouse.y, 1.)) * pos;
  mat4 projection = projection(pos, aspect, -0.5, 100.);
  gl_Position = projection * pos;
  gl_PointSize = 10.;
  v_color = vec4(clamp(0., 1., 2.*(1.-abs(i-1.))), clamp(0., 1., 2.*(1.-abs(i-2.))), max(clamp(0., 1., 2.*(1.-abs(i-3.))), clamp(0., 1., 2.*(1.-abs(i)))), 1.);

}