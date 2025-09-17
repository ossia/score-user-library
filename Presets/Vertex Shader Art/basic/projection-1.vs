/*{
  "DESCRIPTION": "projection",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/SqctCGQnp8j6NNnSE)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 4368,
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
    "ORIGINAL_VIEWS": 48,
    "ORIGINAL_DATE": {
      "$date": 1514494556121
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 21.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
 vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
   vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
   return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  // Set up vertices
  vec3 vert;
  if (vertexId == 0.0) {
   vert = vec3(0.5, 0.0, 0.0);
  } else if (vertexId == 1.0) {
   vert = vec3(0.0, 0.5, 0.0);
  } else if (vertexId == 2.0) {
   vert = vec3(0.0, -0.5, 0.0);
  }

  gl_Position = vec4(vert, 1.0);
  v_color = vec4(1.0, 1.0, 1.0, 1.0);
}