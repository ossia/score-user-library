/*{
  "DESCRIPTION": "cubes1",
  "CREDIT": "pgan (ported from https://www.vertexshaderart.com/art/gBqWsGGvjPsKNMGja)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 14400,
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1554745867355
    }
  }
}*/

//#define CUBES_PER_ROW 20.0
#define CUBES_PER_ROW 20.0
//#define CUBE_SPACING 0.05
#define CUBE_SPACING 0.075

float rotr3(float x, float n) {
  return floor(x / pow(2.0, n)) + mod(x * pow(2.0, 3.0 - n), 8.0);
}

float mod2(float x) {
  return mod(floor(x), 2.0);
}

vec3 cubePos(float x) {
  return vec3(mod2(x), mod2(x / 2.0), mod2(x / 4.0));
}

void main() {
  float near = -1.0;
  float far = 0.99;

  float aspectRatio = resolution.y / resolution.x;

  float cubeIdx = floor(vertexId / 36.0);
  float faceIdx = mod(floor(vertexId / 6.0), 6.0);
  float faceDiv3 = floor(faceIdx / 3.0);
  float faceMod3 = mod(faceIdx, 3.0);
  float quadIdx = mod(vertexId, 6.0);
  float baseIdx = faceIdx * 6.0;
  float vertIdx = abs(faceDiv3 == 0.0 ? quadIdx - 2.0 : 3.0 - quadIdx);

  vec3 pos = cubePos(mod(rotr3(vertIdx, 2.0 - faceMod3) + pow(2.0, faceMod3) * faceDiv3, 8.0));
  pos -= 0.5;
  pos *= 0.02;

  float ct = time + mod(cubeIdx, CUBES_PER_ROW);
  float ct1 = time + floor(cubeIdx / CUBES_PER_ROW);

  float s = sin(ct*0.37), c = cos(ct*0.37);
  float s1 = sin(ct1), c1 = cos(ct1);

  mat4 rot = mat4(vec4(c, s, 0.0, 0.0),
        vec4(-s, c, 0.0, 0.0),
        vec4(0.0, 0.0, 1.0, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0));

  mat4 rot2 = mat4(vec4(c1, 0.0, s1, 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(-s1, 0.0, c1, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0));

  gl_Position = vec4(pos, 1.0) * rot * rot2;
  // gl_Position = vec4(pos, 1.0) * rot2;

  // gl_Position.x += (mod(cubeIdx, CUBES_PER_ROW) - CUBES_PER_ROW/2.0) * (1.0/CUBES_PER_ROW);
  // gl_Position.y += (floor(cubeIdx / CUBES_PER_ROW) - CUBES_PER_ROW/2.0) * (1.0/CUBES_PER_ROW);
  gl_Position.x += (mod(cubeIdx, CUBES_PER_ROW) - CUBES_PER_ROW/2.0) * (CUBE_SPACING);
  gl_Position.y += (floor(cubeIdx / CUBES_PER_ROW) - CUBES_PER_ROW/2.0) * (CUBE_SPACING);

  gl_Position.y /= aspectRatio;
  float zDist = gl_Position.z - near;
  gl_Position.w = zDist;

  v_color = vec4(mod2(faceIdx + 1.0), mod2((faceIdx + 1.0) / 2.0), mod2((faceIdx + 1.0) / 4.0), 1.0);
}
