/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/6kjKSErWMZSF6xj6c)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 449,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 83,
    "ORIGINAL_DATE": {
      "$date": 1512734459827
    }
  }
}*/

void main() {
  float id = vertexId;

  float ux = floor(id / 4.) + mod(id, 2.);

  float vy = mod(floor(id / 2.) + floor(id / 4.), 2.);

  float angle = ux * radians(318.0) / cos(time* 20.2)*(vertexCount * 0.00333333);
  float c = cos(angle);
  float s = sin(angle);

  float radius = vy * 2.;

  float a = resolution.x / resolution.y-mouse.y;

  float x = c * radius / (.1 -a);
  float y = s * radius;

  vec2 xy = vec2(x,y);
  gl_Position = vec4(xy* .5, 0.1, 0.6);
  v_color = vec4(1, sin(time*8.), tan(12.00/time)*23., 1);
}