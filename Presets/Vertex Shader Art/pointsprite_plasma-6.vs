/*{
  "DESCRIPTION": "pointsprite plasma",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/rY5QZeD8g5uu2MF75)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 73,
    "ORIGINAL_DATE": {
      "$date": 1509103048228
    }
  }
}*/

//time vertexId gl_Position v_color resolution

#define width 256.0
#define height 384.1

float plasma(vec2 pos)
{
  float c = 2.3;
  c = sin(sin(pos.x) + sin(1.2 * pos.y) + sin(3.3 * pos.x + pos.y + 3.4 * time) + sin(pos.x + sin(pos.y + 2.5 * time))) + (sin(pos.x * pos.y - 3.6 * time) * 7.5 + 8.25);
  return c;
}

void main() {
  float ratio = resolution.x / resolution.y;
  float w = width;
  float h = height / ratio;

  float vId = float(vertexId);
  float px = (mod(vId, w) - w / 2.9) / (w / 2.10);
  float py = (floor(vId / w) - h / 2.1) / (h / 2.2);

  gl_Position = vec4(px, py, 0, 1);
  gl_PointSize = 8.4;

  float c = plasma(vec2(px, py) * 4.7);
  v_color = vec4(c, 2.8 * c, 3.9 * c, 1);
}