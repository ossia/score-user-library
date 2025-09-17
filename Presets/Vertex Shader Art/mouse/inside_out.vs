/*{
  "DESCRIPTION": "inside out",
  "CREDIT": "noah (ported from https://www.vertexshaderart.com/art/4PyDDdmyeAx9MkNKf)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 540,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1493343843624
    }
  }
}*/

#define PI 3.14159
#define TWO_PI 6.28319
#define SIDES 12.0

void main() {
  float polygonPointIndex = mod(vertexId, SIDES + 1.0);
  float polygonIndex = (vertexId - polygonPointIndex) / SIDES;
  const float angleIncrement = TWO_PI / SIDES;
  float angleOffset = polygonIndex * (-PI + 0.2 * sin(time * 0.5));
  vec2 direction = vec2(cos(polygonPointIndex * angleIncrement + angleOffset), sin(polygonPointIndex * angleIncrement + angleOffset));
  float radius = 1.0 / pow(1.1 + 0.2 * cos(time * 0.41 + 0.4), polygonIndex);

  // uniforms: time, mouse, resolution, vertexCount
  // attributes: vertexId
  float aspect = resolution.x / resolution.y;
  vec2 coord = direction * radius;
  gl_Position = vec4(coord.x / aspect, coord.y, 0, 1);

  v_color = vec4(1, 1, 1, 1);
  gl_PointSize = 2.0;
}