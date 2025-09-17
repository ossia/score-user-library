/*{
  "DESCRIPTION": "cubes2",
  "CREDIT": "matt (ported from https://www.vertexshaderart.com/art/tjBqEBhdzGA4XCiWr)",
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
    "ORIGINAL_VIEWS": 517,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1446492999054
    }
  }
}*/

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
  float aspectRatio = resolution.y / resolution.x;
  float cubeIdx = floor(vertexId / 36.0);
  float faceIdx = mod(floor(vertexId / 6.0), 6.0);
  float faceDiv3 = floor(faceIdx / 3.0);
  float faceMod3 = mod(faceIdx, 3.0);
  float quadIdx = mod(vertexId, 6.0);
  float baseIdx = faceIdx * 6.0;
  float vertIdx = abs(faceDiv3 == 0.0 ? quadIdx - 2.0 : 3.0 - quadIdx);
  vec3 pos = cubePos(rotr3(vertIdx + faceDiv3 * 4.0, faceMod3));
  pos -= 0.5;
  pos *= 0.02;

  float gridX = (mod(cubeIdx, 20.0) - 10.0) / 20.0;
  float gridY = floor(cubeIdx / 20.0 - 10.0) / 20.0;
  float dist = length(vec2(gridX, gridY));
  float ct = sin(time + gridX * 4.0) * sin(time + gridY * 4.0);
  float ct1 = cos(time + gridX * 4.0) * cos(time + gridY * 4.0);
  float s = sin(ct + time), c = cos(ct + time);
  float s1 = sin(ct1 + time), c1 = cos(ct1 + time);
  mat3 rotZ = mat3(vec3(c, s, 0.0), vec3(-s, c, 0.0), vec3(0.0, 0.0, 1.0));
  mat3 rotY = mat3(vec3(c1, 0.0, s1), vec3(0.0, 1.0, 0.0), vec3(-s1, 0.0, c1));
  pos = pos * rotZ * rotY;
  pos.x += gridX;
  pos.y += gridY;
  pos.y /= aspectRatio;
  float zDist = pos.z - near;
  gl_Position = vec4(pos, zDist);

  float colIdx = faceIdx + 1.0;
  v_color = vec4(mod2(colIdx), mod2(colIdx / 2.0), mod2(colIdx / 4.0), 1.0);
}