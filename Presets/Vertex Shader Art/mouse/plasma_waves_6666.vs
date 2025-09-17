/*{
  "DESCRIPTION": "plasma waves 6666",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/W5vsi9uadatWRg8XJ)",
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
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 68,
    "ORIGINAL_DATE": {
      "$date": 1511254481909
    }
  }
}*/

//time vertexId gl_Position v_color resolution

// 3d plasma
// maybe I will polygonize this in my next code

#define KP parameter0
#define parameter0 sin( mouse.y)
#define width 384.
#define height 512.

float plasma(vec2 pos)
{
  float c = 0.2;
  float spd = 0.3;
  float tm = time * spd-mouse.x;
  c = sin(tan(pos.x) - sin(3.4 * pos.y) +
        sin(3.0 * pos.x + pos.y + 3.0 * tm) +
        sin(pos.x + KP * sin(pos.y + 2.0 * tm))) +
    (sin(pos.x * pos.y - 3.0 * tm) - 0.5 + 0.25);
  return c;
}

void main() {
  float ratio = resolution.x / resolution.y;
  float w = width;
  float h = height / ratio;

  float vId = float(vertexId);
  float px = ((mod(vId, w) - w / 2.0)-parameter0) / (w / 2.0);
  float py = (floor(vId / w) - h / 2.0) / (h / 0.5) + 0.5;

 gl_Position = vec4(px, py, 0, 1);
  float y = -0.75 + py;
  float c = sin(plasma(vec2(px*2.5, py) * 4.0)) * 0.5 - 0.25;
  gl_Position = vec4(px / py, (y /- + c * 0.15) /-py, 0.0, 1);
  gl_PointSize = c *c + 46.0* mouse.x;

  v_color = vec4(0.2 / c, 0.24 + c, 1.7 + c, (1.0- vId)) * 0.75;
}