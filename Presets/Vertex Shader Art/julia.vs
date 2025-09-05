/*{
  "DESCRIPTION": "julia",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/7YtDi4LTcGHk4Rv7A)",
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
    0.5725490196078431,
    0.2549019607843137,
    0.7450980392156863,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 34,
    "ORIGINAL_DATE": {
      "$date": 1680910301424
    }
  }
}*/

//time vertexId gl_Position v_color resolution

#define width 256.0
#define height 384.0

float plasma(vec2 pos, float w, float h)
{
  float c = 0.0;
  c = sin(sin(pos.x) + sin(1.4 * pos.y) + sin(3.0 * pos.x + pos.y + 3.0 * time) + sin(pos.x + sin(pos.y + 2.0 * time))) + (sin(pos.x * pos.y - 3.0 * time) * 0.5 + 0.25);
  float newRe = 1.5 * (pos.x - w / 2.0) / (0.5 * w);
  float newIm = (pos.y - h / 2.0) / (0.5 * h);
  float oldRe;
  float oldIm;
  float j = 0.0;
  for(int i = 0; i < 128; i++)
        {
        j+=1.0;
        oldRe = newRe;
        oldIm = newIm;
        newRe = oldRe * oldRe - oldIm * oldIm + 0.4;
        newIm = 2.0 * oldRe * oldIm + sin(time/1.0);
        if((newRe * newRe + newIm * newIm) > 4.0) break;
        }
  return j/64.0;
}

void main() {
  float ratio = resolution.x / resolution.y;
  float w = width;
  float h = height / ratio;

  float vId = float(vertexId);
  float px = (mod(vId, w) - w / 2.0) / (w / 2.0);
  float py = (floor(vId / w) - h / 2.0) / (h / 2.0);

  gl_Position = vec4(px, py, 0, 1);
  gl_PointSize = 8.0;

  float c = plasma(vec2(px+0.5, py+0.5)*100.0,px+w/2.0,py+h/2.0);
  v_color = vec4(c, 2.0 * c, 3.0 * c, 1);
}