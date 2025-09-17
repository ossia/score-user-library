/*{
  "DESCRIPTION": "P04-Ej02",
  "CREDIT": "alejandrocamara (ported from https://www.vertexshaderart.com/art/TnA8pckZzDwoPmYvM)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 8280,
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
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1553029252655
    }
  }
}*/

void main() {

  //float phi = mod((vertexId / 180.0), 180.0);
  //float theta = mod(vertexId, 360.0);

  //float phi = floor(vertexId/ 180.0);
  //float theta = floor(vertexId/ 360.0);

  //float phi = (floor(vertexId / 180.0));
  //float theta = (mod(vertexId, 360.0)) ;

  float phi = radians(floor(vertexId / 180.0)) * 4.0;
  float theta = radians(mod(vertexId, 360.0)) * 4.0;
  float p = 1.0;

  mat4 rotX = mat4(
    1, 0, 0, 0,
   0, cos(time ), -sin(time), 0,
    0, sin(time ), cos(time ), 0,
    0, 0, 0, 1
  );

  mat4 rotY = mat4(
   cos(time ), 0, sin(time), 0,
   0, 1, 0, 0,
    -sin(time), 0, cos(time ), 0,
    0, 0, 0, 1
  );

  mat4 rotZ = mat4(
   cos(time), -sin(time ), 0, 0,
   sin(time), cos(time ), 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
  );

  float x = p * sin(phi) * cos(theta);
  float y = p * sin(phi) * sin(theta);
  float z = p * cos(phi);

  vec4 pos = vec4(x,y,z, 1.0);
  //gl_Position = vec4(pos) / 0.1;
  gl_Position = vec4(rotX * rotZ * pos) / 0.1;
  v_color = vec4(0.0, 0.0, 1.0, 1.0);
  gl_PointSize = 3.0;

}