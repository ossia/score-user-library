/*{
  "DESCRIPTION": "rot",
  "CREDIT": "ale (ported from https://www.vertexshaderart.com/art/HKJSL9FWrAxtLhmyf)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "LINES",
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
      "$date": 1518223864345
    }
  }
}*/

 /* float theta = radians(0.0)< angle <radians(180.0);
  float fi = radians(0.0) < angle < radians(360.0)
  float ux = radius * sin(theta) * cos(fi); */

void main()
{
   float theta = radians(mod(vertexId, 180.0));
   float phi = radians(floor(vertexId / 180.0));

  float x = sin(theta) * cos (phi);
  float y = sin(theta) * sin (phi);
  float z = cos (theta);

  mat4 rotX = mat4(1.0);
  rotX[1][1] = cos(time);
  rotX[2][1] = -sin(time);
  rotX[1][2] = sin(time);
  rotX[2][2] = cos(time);

  vec3 xyz = vec3(x, y, z)*0.7;

  gl_Position = rotX * vec4(xyz, 1.0);
  gl_PointSize = 1.0;
  v_color = vec4(1.0, 0.0, 0.0, 1.0);

}