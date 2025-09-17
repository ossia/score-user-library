/*{
  "DESCRIPTION": "First Naive Starfield - First naive implementation of a starfield.",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/jabgpFXjj8umhyfzH)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Nature"
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
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_DATE": {
      "$date": 1523371418615
    }
  }
}*/

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
  float n = vertexId / vertexCount;
  float randX = rand(vec2(n, 10.0));
  float randY = rand(vec2(10.0, n));

  float x = randX * 10.0;
  float y = randY * 10.0;
  float vy = mod((n * n) * time * 0.1, 2.0) + n * 5.0;

  gl_Position = vec4(x - 5.0, y - vy, 0, n);
  gl_PointSize = n * 2.0;
  v_color = vec4(n, n, abs(cos(time * n)), n);
}