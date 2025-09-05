/*{
  "DESCRIPTION": "the_spiral",
  "CREDIT": "the (ported from https://www.vertexshaderart.com/art/4FbgY4x8sEM5EQuCT)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1234,
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1635179449976
    }
  }
}*/

#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
const float TWOPI = radians(360.);
float aspect = resolution.x / resolution.y;

vec3 hsv2rgb(vec3 hsvValue) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(hsvValue.xxx + K.xyz) * 6.0 - K.www);
  return hsvValue.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsvValue.y);
}

float circle1() {
 float x = vertexId - 1.;
 x *= TWOPI;
 x /= vertexCount / 5. - 1.;
 return x;
}
float circle2() {
  float edgeRate = 10.;
  float edgesCount = vertexCount * edgeRate;
 // return (1. - 0.1 * vertexId / edgesCount) * sin(time + vertexId); // muita giro!
 //return (1. - 0.1 * vertexId / edgesCount); // lollipop
 // return (1. - 0.1 * vertexId / edgesCount) * (cos(time) + 3.) / 4.; // pulsing lollipop
 // return (1. - 0.1 * vertexId / edgesCount) * (cos(time + vertexId) + 3.) / 4.; // flor ?
 // return (1. - 0.1 * vertexId / edgesCount) - (cos(time + vertexId) + 3.) / 30.; // hypnotic
 // return (1. - vertexId / vertexCount) - (cos(time + vertexId)) / (vertexId + 1.) / vertexCount / 30.;
 return (1. - edgeRate * vertexId / edgesCount) - (cos(time + vertexId)) / (vertexId + 1.) / edgesCount / 30.;
 // return (7./8.);
}

void main() {
 int index = int(floor(time));
 float ratio = fract(time);

 float m = step(0.5, float(vertexId)); // vertexId[0] = (0, 0)
 //m *= (1. - step(floor(time) + 2., float(vertexId))); // clock effect

 float c1 = circle1();
 float c2 = circle2();

  float divider = 1./vertexCount;

 vec2 pos = vec2(sin(c1 / divider) / aspect * c2, cos(c1 / divider) * c2);

 gl_Position = vec4(m * pos, -vertexId / 10000., 1);

 v_color = m * vec4(hsv2rgb(vec3(float(vertexId) / float(vertexCount), 1., 1.)), 1.) + (1. - m) * vec4(.0);
}