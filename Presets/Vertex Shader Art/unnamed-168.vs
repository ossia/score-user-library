/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/rF2WSQ98F7YxgjTH9)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 102,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 79,
    "ORIGINAL_DATE": {
      "$date": 1560434605290
    }
  }
}*/

void main() {
  float id = vertexId;

  float ux = floor(id / 6.) + mod(id, 2.);

  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);

  float angle = ux * radians(180.0) / (vertexCount * sin(time) * 0.009);
  float c = cos(angle);
  float s = sin(angle);

  float radius = vy;

  float a = resolution.x / resolution.y;

  float x = c * radius / a;
  float y = s * radius;

  vec2 xy = vec2(x,y);
  gl_Position = vec4(xy* .5, 0, 1);
  v_color = vec4(1, 0, 0, 1);
}