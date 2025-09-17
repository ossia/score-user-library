/*{
  "DESCRIPTION": "Crap",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/wnJ3yTrs7ZQXEmwRM)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 132,
    "ORIGINAL_DATE": {
      "$date": 1462302171138
    }
  }
}*/

#define PI radians(180.)

void main() {

  float stripId = mod(vertexId, 2.0);
  float norId = vertexId / vertexCount;

  float x = norId - 0.5;
  float y = stripId - 0.5;

  float ar = resolution.x / resolution.y;

  y += sin(x * 50.0) * sin(time);
  y *= cos(time);

  vec2 p = vec2(x * ar, y);
  p.y -= abs(norId - 0.5) * 2.0;

  gl_Position = vec4(p.x, p.y, 0, 1);

  v_color = vec4(1,1,1,1);
}