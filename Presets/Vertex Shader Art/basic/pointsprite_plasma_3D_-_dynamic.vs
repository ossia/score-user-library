/*{
  "DESCRIPTION": "pointsprite plasma 3D - dynamic",
  "CREDIT": "8bitrick (ported from https://www.vertexshaderart.com/art/n4dz8Mdn2qsYrcyZq)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 10000,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1449501232810
    }
  }
}*/

//time vertexId gl_Position v_color resolution vertexCount

// -- Just added the dynamic width and height to allow different # of vertices --
//

// 3d plasma
// maybe I will polygonize this in my next code

#define temp sqrt(vertexCount / 0.24)
#define width temp*0.6
#define height temp*0.4

float plasma(vec2 pos)
{
  float c = 0.0;
  c = sin(sin(pos.x) + sin(3.4 * pos.y) + sin(3.0 * pos.x + pos.y + 3.0 * time) + sin(pos.x + sin(pos.y + 2.0 * time))) + (sin(pos.x * pos.y - 3.0 * time) * 0.5 + 0.25);
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
  float c = sin(plasma(vec2(px+0.5, py) * 4.0)) * 0.5 + 0.25;
  gl_Position = vec4(px / py, (y + c * 0.15) / py, 0.0, 1);
  gl_PointSize = 1.0;

  v_color = vec4(0.5 + c, 0.5 + c, 1.5 + c, 1) * 0.75;
}