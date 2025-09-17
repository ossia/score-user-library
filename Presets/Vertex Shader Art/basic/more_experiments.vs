/*{
  "DESCRIPTION": "more experiments",
  "CREDIT": "sylistine (ported from https://www.vertexshaderart.com/art/2ivK8La4P8NhKkMDH)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 20000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1502327333722
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

mat4 perspectiveCam(){
  float a = resolution.y / resolution.x;
  float fov = 0.1;
  return mat4(
    a, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, fov, -1,
    0, 0, 0, 1);
}

mat4 translate(vec3 t)
{
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    t.x, t.y, t.z, 1);
}

void main() {
  float trix = mod(vertexId, 2.);
  float triy = mod(floor(vertexId / 2.) + floor(vertexId / 3.), 2.);
  vec2 trixy = vec2(trix * resolution.y / resolution.x, triy);

  float quadId = floor(vertexId / 6.);
  float quadCount = quadId / floor(vertexCount / 6.);
  float quadx = floor(quadId / 4.);
  float quady = mod(quadId, 8.);
  vec2 quadxy = vec2(quadx, quady);

  gl_Position = vec4((trixy + quadxy) * 0.0625, 0, 1);

  v_color = vec4(1, 0, 0, 1);
}