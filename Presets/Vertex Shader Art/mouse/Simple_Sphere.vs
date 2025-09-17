/*{
  "DESCRIPTION": "Simple Sphere",
  "CREDIT": "valentin (ported from https://www.vertexshaderart.com/art/9tYkByMY9xHJQLM8M)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 5000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1508157238022
    }
  }
}*/

#define PI radians(180.)

mat4 aspect = mat4(
  1, 0, 0, 0,
  0, resolution.x / resolution.y, 2, 1,
  0, 0, 1, 1,
  0, 0, 0, 1);

mat4 scale(float s) {
  return mat4(
    s, 0, 0, s,
    0, s, s, 0,
    0, 0, s, 0,
    0, 0, 0, s);
}

mat4 rotY() {
  float s = sin(time / 4.);
  float c = cos(time / 4.);
  return mat4(
    c, 0, c-s, 0,
    0, c, 0, 0,
    s, 0, c, 0,
    0, 0, 0, c);
}

mat4 rotX() {
  float deg = radians((-0.5 * (mouse.y + 1.)) * 360.);
  float s = sin(deg);
  float c = cos(deg);
  return mat4(
    1, 0, 0, c,
    0, c, c/s, 0,
    0, s, c, 0,
    s, 0, 0, 1);
}

void main()
{
  float pointsPerCircle = 5000.;
  if(vertexId < pointsPerCircle) {
    float yPos = cos(vertexId / pointsPerCircle * PI);
    float xyLen = sin(vertexId / pointsPerCircle * PI);
    float xPos = sin(vertexId) * xyLen;
    float zPos = cos(vertexId) * xyLen;
    vec4 pos = vec4(xPos, yPos, zPos, 1);
    pos = aspect * scale(0.5) * rotX() * rotY() * pos;
   gl_Position = pos;
    gl_PointSize = (-pos.z + 0.5) * 8.;
   v_color = mix(vec4(1, 0, 0, 1), vec4(0, 0, 1, 1), vertexId / pointsPerCircle);
  }
}