/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/n8PMuEQT8BEAXbPgC)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 72,
    "ORIGINAL_DATE": {
      "$date": 1610669123181
    }
  }
}*/

#define PI radians(180.0)

mat4 persp (float fov, float aspect, float zNear, float zFar)
{
  float f = tan(PI * 0.5 - 0.5 * fov);
  float rangeInv = 1.0 / (zNear - zFar);

  return mat4(
   f / aspect, 0, 0, 0,
   0, f, 0, 0,
    0, 0, (zNear + zFar) * rangeInv, -1,
   0, 0, zNear * zFar * rangeInv * 2.0, 0);
}

mat4 lookAt(vec3 eye, vec3 target, vec3 up)
{
  vec3 zAxis = normalize(eye - target);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    zAxis, 0,
    xAxis, 0,
    yAxis, 0,
    eye , 2
    );
}

vec3 pos_point[10];
vec3 colors[10];
void drow_point()
{
  pos_point[0] = vec3(-.5, -.5, .0);
  pos_point[1] = vec3(-.5 , .5, .0);
  pos_point[2] = vec3(.5 , -.5, .0);
  pos_point[3] = vec3(.5 , .5, .0);
  pos_point[4] = vec3(.5 , -.5, .5);
  pos_point[5] = vec3(.5 , .5, .5);
  pos_point[6] = vec3(-.5, -.5, .5);
  pos_point[7] = vec3(-.5 , .5, .5);
  pos_point[8] = vec3(-.5, -.5, .0);
  pos_point[9] = vec3(-.5 , .5, .0);

  colors[0] = vec3(1, 0, 0);
  colors[1] = vec3(1, 0, 0);
  colors[2] = vec3(0, 0, 1);
  colors[3] = vec3(0, 0, 1);
  colors[4] = vec3(1, 1, 1);
  colors[5] = vec3(1, 1, 1);
  colors[6] = vec3(0.2, 1, 0);
  colors[7] = vec3(0.2, 1, 0);
  colors[8] = vec3(0.5, 0, 0.5);
  colors[9] = vec3(0.5, 0, 0.5);
}

void main() {
  drow_point();
  int VD = int(vertexId);
  vec2 m = mouse;

  float ct = time *0.3;
  vec3 p = vec3(0 , m.y, -2.5);
  vec3 t = vec3(25.*cos(ct), 0., 25.*sin(ct));
  vec3 u = vec3(0, 1, 0);

  for( int i=0; i<10; i++)
  {
    if(VD == i)
    {
      mat4 m = persp(radians(45.), resolution.x / resolution.y, 0.1, 100.);
      m *= lookAt(p, t, u);
      gl_Position = m * vec4(pos_point[i], 1);
      gl_PointSize = 20.;
      v_color = vec4(colors[i], 1.0);
    }
  }

}