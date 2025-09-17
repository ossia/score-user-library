/*{
  "DESCRIPTION": "camera transform vs vertex position logic exercise",
  "CREDIT": "sylistine (ported from https://www.vertexshaderart.com/art/dLyBG6jnNceKnhqbB)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 20000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.4980392156862745,
    0.4980392156862745,
    0.4980392156862745,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1501294812465
    }
  }
}*/

#define PI radians(180.)
#define TAU (2. * PI)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

mat4 rotZ() {
  float s = sin(time);
  float c = cos(time);
  return mat4(
    c, -s, 0, 0,
    s, c, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1);
}

mat4 rotY() {
  float val = time * 20.;
  float s = sin(radians(val));
  float c = cos(radians(val));
  return mat4(
    c, 0, -s, 0,
    0, 1, 0, 0,
    s, 0, c, 0,
    0, 0, 0, 1);
}

mat4 cameraFrustum = mat4(
  1, 0, 0, 0,
  0, resolution.x / resolution.y, 0, 0,
  0, 0, 1, -1,
  0, 0, 0, 1);

void main() {
  mat4 cameraTransform = mat4(
    1, 0, 0, 0,
   0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1);
  cameraTransform = rotY() * cameraTransform;

  float triId = floor(vertexId / 3.);
  float triIdx = mod(vertexId, 3.);

  vec4 triCenter = vec4(triId * 2., 0, 0, 1);
  vec4 triPos = rotZ() * vec4(sin(triIdx * radians(120.)), cos(triIdx * radians(120.)), 0, 1);
  vec4 vPos = triCenter + triPos;

  gl_Position = (cameraFrustum * cameraTransform * vPos);
  v_color = vec4(mod(vertexId, 3.), mod(vertexId + 1., 3.), mod(vertexId + 2., 3.), 1);
}