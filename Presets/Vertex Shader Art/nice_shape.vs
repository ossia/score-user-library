/*{
  "DESCRIPTION": "nice shape",
  "CREDIT": "tjak (ported from https://www.vertexshaderart.com/art/qGKmWQ4t3CedrMdN2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 36,
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
      "$date": 1559503789224
    }
  }
}*/

#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 triangle(int vtx) {
  if (vtx == 0) {
    return vec3(-1.0, -1.0, 0.0);
  } else if (vtx == 1) {
    return vec3(0.0, 1.0, 0.0);
  } else if (vtx == 2) {
    return vec3(1.0, -1.0, 0.0);
  } else {
    return vec3(0.0, sin(time)*sin(time), 0.0);
  }
}

void main() {
  float triangleId = floor(vertexId / 3.0);
  float triangleCount = floor(vertexCount / 3.0);
  float triVtx = mod(vertexId, 3.0);

  // uniformly spaced in (0, 1)
  float t = mix(triangleId/triangleCount,
        (triangleId+1.)/triangleCount,
        0.5);

  float angle = 2. * PI * t;
  angle += time;
  vec3 pos = triangle(int(triVtx));
  mat3 rot = mat3(
    vec3(cos(angle), -sin(angle), 0.0),
    vec3(sin(angle), cos(angle), 0.0),
    vec3(0.0, 0.0, 1.0)
  );
  mat3 scal = mat3(0.2);
  pos = scal * rot * pos;

  pos.y *= resolution.x/resolution.y;

  gl_Position = vec4(pos, 1.0);
  vec3 col = hsv2rgb(vec3(t, 0.7, 0.7));
  v_color = vec4(col, 1.0 - t);
}