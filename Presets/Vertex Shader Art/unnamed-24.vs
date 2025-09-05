/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/6xC43NutGGXHRTZ9p)",
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
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 72,
    "ORIGINAL_DATE": {
      "$date": 1611109847725
    }
  }
}*/

#define PI radians(180.0)
const int max_v = 12;
vec3 poi_v[max_v];
vec3 point[max_v+2];
vec3 color[max_v+2];

float z[2];

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

void drow_point()
{
  z[0] = 0.;
  z[1] = 1.;

  for(int i=0; i<max_v; i++)
  {
    poi_v[i] = vec3(cos(float(i)), sin(float(i)), z[int(floor(float(i)/6.))]);
  }
}

void f_point()
{
  drow_point();

  point[0] = poi_v[0];
  point[1] = poi_v[6];
  point[2] = poi_v[1];
  point[3] = poi_v[7];
  point[4] = poi_v[2];
  point[5] = poi_v[8];
  point[6] = poi_v[3];
  point[7] = poi_v[9];
  point[8] = poi_v[4];
  point[9] = poi_v[10];
  point[10] = poi_v[5];
  point[11] = poi_v[11];
  point[12] = poi_v[0];
  point[13] = poi_v[6];

  for(int i=0; i<12+2; i++)
  {
    float x = float(i);
    color[i]= vec3(floor(x/2.)-floor(x)*0.5+1.);
  }
}

/*
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
*/

void main() {
  f_point();
  int VD = int(vertexId);
  vec2 m = mouse;

  float ct = time *0.3;
  vec3 p = vec3(0 , m.y*2., -4.5);
  vec3 t = vec3(25.*cos(ct), m.x*13., 25.*sin(ct));
  vec3 u = vec3(0, 1, 0);

  for( int i=0; i<12+2; i++)
  {
    if(VD == i)
    {
      mat4 m = persp(radians(45.), resolution.x / resolution.y, 0.1, 100.);
      m *= lookAt(p, t, u);
      gl_Position = m * vec4(point[i], 1);
      gl_PointSize = 20.;
      v_color = vec4(color[i], 1.0);
    }
  }

}