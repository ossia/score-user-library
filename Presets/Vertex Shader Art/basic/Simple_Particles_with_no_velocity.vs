/*{
  "DESCRIPTION": "Simple Particles with no velocity??? - Glad I can get a bunch of points on the screen and get them working. Thinking like this are quite different from the canvas in JavaScript and immediate mode programming.",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/G3infoeL8fLc5SiDQ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Abstract"
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
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1523285012357
    }
  }
}*/

float rand(vec2 co){
    return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
  float n = vertexId / vertexCount;
  float pointSize = n * 3.0;
  float width = 5.0;
  float height = 5.0;
  float randomX = rand(vec2(vertexId, 5.0));
  float randomY = rand(vec2(vertexId, 10.0));

  float xOff = cos(time * n) * 0.25;
  float yOff = sin(time * n * n) * 0.3 * n;

  float x = randomX * width + xOff;
  float y = height * randomY + yOff;

  gl_Position = vec4(x - 1.0, y - 1.0, 0.0, 1.0);
  gl_PointSize = pointSize;
  v_color = vec4(n, cos(time), n, 1.0);
}