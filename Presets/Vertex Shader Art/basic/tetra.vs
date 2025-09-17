/*{
  "DESCRIPTION": "tetra - basket",
  "CREDIT": "tjak (ported from https://www.vertexshaderart.com/art/TcJgksCcEE95aJXZc)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 9,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0.027450980392156862,
    0.08627450980392157,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1559532732025
    }
  }
}*/

#define TAU radians(360.)
#define TAU_2 radians(180.)
#define TAU_3 radians(120.)
#define TAU_4 radians(90.)

#define PI TAU_2

vec3 hsv2rgb(vec3 c);
vec2 triangle(int vtx);

void main() {
  float triangleId = floor(vertexId / 3.0);
  float triangleCount = floor(vertexCount / 3.0);
  float triVtx = mod(vertexId, 3.0);

  float angle = TAU_3 * triangleId;
  vec3 pos = vec3(triangle(int(triVtx)), 1.0);

  mat3 rot = mat3(
    vec3(cos(angle), sin(angle), 0.0),
    vec3(-sin(angle), cos(angle), 0.0),
    vec3(0.0, 0.0, 1.0)
  );
  mat3 scal = mat3(0.6);
  pos = scal * rot * pos;

  // correct for aspect ratio
  pos.y *= resolution.x/resolution.y;
  gl_Position = vec4(pos, 1.0);

  float t = mix(triangleId/triangleCount, (triangleId+1.)/triangleCount, 0.5);
  vec3 col = hsv2rgb(vec3(0.25 * mod(triangleId, 4.0), 0.7, 0.7));
  v_color = vec4(col, 1.0);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 triangle(int vtx) {
  if (vtx == 0) {
    return vec2(-0.5, -0.5);
  } else if (vtx == 1) {
    return vec2(0.0, 0.0);
  } else if (vtx == 2) {
    return vec2(0.5, -0.5);
  } else {
    return vec2(0.0, sin(time)*sin(time));
  }
}
