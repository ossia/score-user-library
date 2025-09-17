/*{
  "DESCRIPTION": "sphere",
  "CREDIT": "gerrygoo (ported from https://www.vertexshaderart.com/art/xyMYnHS29GDusyzJp)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1553468157975
    }
  }
}*/

#define two_pi radians(360.0)
#define rot_x mat3(1, 0, 0, 0, cos(time), -sin(time), 0, sin(time), cos(time))
#define rot_z mat3(cos(time), -sin(time), 0, sin(time), cos(time), 0, 0, 0, 1)

void main() {

  float
    per_circle = 100.0,
    r = 0.8,

    x = mod(vertexId, per_circle),
    y = floor(vertexId / per_circle),

    ph = x / per_circle * two_pi,
    th = y / per_circle * two_pi;

  vec3 pos = vec3(
   r * sin(ph) * cos(th),
    r * sin(ph) * sin(th),
    r * cos(ph)
  );

  gl_Position = vec4(
    rot_x * rot_z * pos,
    1
  );

  gl_PointSize = 5.0;
  v_color = vec4(0, 0.8, 1, 1);

}