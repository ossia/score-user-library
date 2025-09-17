/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/BxXCFpZxu7eFdhiyP)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 449,
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
    "ORIGINAL_VIEWS": 89,
    "ORIGINAL_DATE": {
      "$date": 1512610172932
    }
  }
}*/

void main() {
  float id = vertexId;

  float ux = floor(id / 6.) + mod(id, 2.);

  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);

  float angle = ux * radians(180.0) / (vertexCount * 0.00333333);
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