/*{
  "DESCRIPTION": "Ej2",
  "CREDIT": "julio (ported from https://www.vertexshaderart.com/art/WnMNfRSbiZgpHz3xc)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 15108,
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
      "$date": 1553047657538
    }
  }
}*/

void main() {
 float p = 0.8;
   float phi = radians(floor(vertexId / 45.0)) * 4.0;
   float theta = radians(mod(vertexId, 45.0)) * 4.0;
   float x = p * sin(phi) * cos(theta);
   float y = p * sin(phi) * sin(theta);
   float z = p * cos(phi);

   mat4 rotz = mat4(cos(time), -sin(time), 0, 0,
        sin(time), cos(time), 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1);
   mat4 rotx = mat4(1, 0, 0, 0,
        0, cos(time), -sin(time), 0,
        0, sin(time), cos(time), 0,
        0, 0, 0, 1);
   gl_Position = rotz * rotx * vec4(x, y, z, 1.0);
    gl_PointSize = 2.0;
   v_color = vec4(0.949, 0.74, 0.2472, 1.0);
}