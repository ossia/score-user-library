/*{
  "DESCRIPTION": "circle",
  "CREDIT": "tjak (ported from https://www.vertexshaderart.com/art/xCT9GJqCjqMs5Zj3m)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 180,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.0392156862745098,
    0.0392156862745098,
    0.0392156862745098,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1556949245704
    }
  }
}*/

#define PI radians(180.0)

mat4 proj() {
  return mat4(
    vec4(1.0, 0.0, 0.0, 0.0),
    vec4(0.0, 1.0, 0.0, 0.0),
    vec4(0.0, 0.0, 1.0, 0.0),
    vec4(0.0, 0.0, 0.0, 1.0)
  );
}

void main() {
  float pointId = vertexId;
  float t = abs(0.01 * time) + (vertexId / vertexCount);

  float theta = 37.*(PI) * t;
  float phi = 71.*PI * t;
  float r = 0.5;

  float x = r * sin(theta) * cos(phi);
  float y = r * cos(theta) * cos(phi);

  y *= resolution.x/resolution.y;
  vec3 pos = vec3(x, y, 0.0);
  gl_Position = proj() * vec4(pos, 1.0);
  gl_PointSize = 4.0;

  v_color = mix(
    vec4(1.0, 0.0, 0.0, 1.0),
    vec4(0.0, 1.0, 0.0, 1.0),
    fract(t)
  );
}