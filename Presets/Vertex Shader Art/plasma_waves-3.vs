/*{
  "DESCRIPTION": "plasma waves",
  "CREDIT": "trip-les-ix (ported from https://www.vertexshaderart.com/art/juXJpMEpt8YSWxSWY)",
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
    "ORIGINAL_VIEWS": 371,
    "ORIGINAL_DATE": {
      "$date": 1567418450982
    }
  }
}*/

//time vertexId gl_Position v_color resolution

// 3d plasma
// maybe I will polygonize this in my next code
#define kp1 -.2
#define width 384.
#define height 512.

float plasma(vec2 pos)
{
  float c = 0.20;
  float spd = 4.96;
  float tm = time * spd;
  c = sin(tan(pos.x) + tan(3.4 * pos.y) +
        sin(3.0 * pos.x + pos.y + 3.0 * tm) +
        sin(pos.x + sin(pos.y + 2.0 * tm))) +
    (sin(pos.x * pos.y - 3.0 * tm) * 0.5 + 0.25);
  return c;
}

void main() {
  float ratio = resolution.x / resolution.y;
  float w = width;
  float h = height / ratio;

  float vId = float(vertexId);
  float px = (mod(vId, w) - w / 2.0) / (w / 2.0);
  float py = (floor(vId / w) - h / 2.0) / (h / 0.5) + 0.5;

  //gl_Position = vec4(px, py, 0, 1);
  float y = -0.75 + py;
  float c = sin(plasma(vec2(px*2., py) * 4.60)) * 0.5 + 0.25;
  gl_Position = vec4(px / py, (y + c * 0.615+kp1) / py, 0.0, 1);
  gl_PointSize = 2.0;

  v_color = vec4(2.2 + c, 0.4 + c, 1.7 + c, 1) * 0.75;
}