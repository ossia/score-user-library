/*{
  "DESCRIPTION": "collage",
  "CREDIT": "visy (ported from https://www.vertexshaderart.com/art/6YpuWT2zbWkg2ocdL)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 14786,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 143,
    "ORIGINAL_DATE": {
      "$date": 1447706679557
    }
  }
}*/

#define PI 3.14159
#define NUM_SEGMENTS 21.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0
//#define FIT_VERTICAL

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

const int max_iterations = 255;

vec2 complex_square( vec2 v ) {
 return vec2(
  v.x * v.x - v.y * v.y,
  v.x * v.y * 2.0
 );
}

void main() {
  float localTime = time*0.02 + 20.0;
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);

    float offset = count * 0.02;

   vec2 cc = vec2(point*0.001+sin(count*0.01+localTime*0.05)*1.,cos(point*0.001+localTime*0.5)*1.1);
 vec2 v = vec2( 0.0 );
 float scale = 0.06;

 int count2 = max_iterations;

 for ( int i = 0 ; i < max_iterations; i++ ) {
  v = cc + complex_square( v );
  if ( dot( v, v ) > 4.0 ) {
   count2 = i;
   break;
  }
 }

  float c3 = float(count2);
  float angle = point * c3 * 1.0 / NUM_SEGMENTS + offset-c3;

  float radius = 0.2-(c3*0.0002);
  float c = cos(angle + localTime) * radius-c3*0.005;
  float s = sin(angle + localTime) * radius-c3*0.005;
  float orbitAngle = count * 0.1*cos(c3);
  float oC = cos(c3*orbitAngle)*cos(orbitAngle + localTime * count * 0.01-c3) * sin(orbitAngle+c3);
  float oS = sin(orbitAngle + localTime * count * 0.01-c3) * sin(orbitAngle+c3);

  #ifdef FIT_VERTICAL
    vec2 aspect = vec2(resolution.y / resolution.x, 1);
  #else
    vec2 aspect = vec2(1, resolution.x / resolution.y);
  #endif

  vec2 xy = vec2(
      oC + c,
      oS + s);
  gl_Position = vec4(xy * aspect, 0, 1);

  float hue = (localTime * 0.01 + count * 1.001);
  v_color = vec4(hsv2rgb(vec3(0.4, hue*0.0003, hue*0.003)), 1);
}