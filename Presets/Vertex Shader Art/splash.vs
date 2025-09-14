/*{
  "DESCRIPTION": "splash",
  "CREDIT": "tjak (ported from https://www.vertexshaderart.com/art/RgpnRrekYqf65qH3v)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 90,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.0392156862745098,
    0.0392156862745098,
    0.0392156862745098,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1557029091265
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

  float x = r * sin(theta) * 1.;// cos(phi);
  float y = r * cos(theta) * cos(phi);

  v_color = mix(
    vec4(1.0, 0.0, 0.0, 1.0),
    vec4(0.0, 1.0, 0.0, 1.0),
    fract(t)
  );

  x += 0.30;
  x += 0.5 * mouse.x;
  y += 0.5 * mouse.y;

  y *= resolution.x/resolution.y;
  vec3 pos = vec3(x, y, 0.0);
  gl_Position = proj() * vec4(pos, 1.0);
  gl_PointSize = 4.0;

}