/*{
  "DESCRIPTION": "Simple Spheres",
  "CREDIT": "sylistine (ported from https://www.vertexshaderart.com/art/oQzXFjHPCApgXWGq3)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 6000,
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
    "ORIGINAL_VIEWS": 119,
    "ORIGINAL_DATE": {
      "$date": 1501115274401
    }
  }
}*/

#define PI radians(180.)

mat4 aspect = mat4(
  1, 0, 0, 0,
  0, resolution.x / resolution.y, 0, 0,
  0, 0, 1, 1,
  0, 0, 0, 1);

mat4 scale(float s) {
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
    0, 0, 0, 1);
}

mat4 rotY() {
  float s = sin(time / 2.);
  float c = cos(time / 2.);
  return mat4(
    c, 0, -s, 0,
    0, 1, 0, 0,
    s, 0, c, 0,
    0, 0, 0, 1);
}

mat4 rotX() {
  float deg = radians((-0.5 * (mouse.y + 1.)) * 360.);
  float s = sin(deg);
  float c = cos(deg);
  return mat4(
    1, 0, 0, 0,
    0, c, -s, 0,
    0, s, c, 0,
    0, 0, 0, 1);
}

void main()
{
  float pointsPerSphere = 1000.;
  float pointsPerLoop = 10.;

  float sphereId = floor(vertexId / pointsPerSphere);
  float spherePointId = mod(vertexId, pointsPerSphere);

  vec4 center = vec4(sin(sphereId) * 5., cos(sphereId) * 5., 0, 1);

  float yPos = cos(spherePointId / pointsPerSphere * PI);
  float xyLen = sin(spherePointId / pointsPerSphere * PI);
  float xPos = sin(spherePointId / pointsPerLoop) * xyLen;
  float zPos = cos(spherePointId / pointsPerLoop) * xyLen;

  vec4 pos = vec4(xPos, yPos, zPos, 1) + center;
  pos = aspect * scale(0.1) * rotX() * rotY() * pos;
  gl_Position = pos;
  gl_PointSize = (-pos.z + 1.) * 4.;
  v_color = mix(vec4(1, 0, 0, 1), vec4(0, 0, 1, 1), spherePointId / pointsPerSphere);
}