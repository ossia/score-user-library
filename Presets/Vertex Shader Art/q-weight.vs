/*{
  "DESCRIPTION": "q-weight",
  "CREDIT": "ilyadorosh (ported from https://www.vertexshaderart.com/art/A6KXiR6FwZEbN6Nh5)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 22957,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1625282406144
    }
  }
}*/

vec3 inv(vec3 a){return 1.-a;}

void main() {

  float width = 40.0;

  float x = mod(vertexId, width);
  float y = floor(vertexId / width);

  float u = x / (width - 1.0);
  float v = y / (width - 1.0);

  float xOffset = cos(time + y * 0.2) * 0.2;
  float yOffset = sin(time + x * 0.3) * 0.1;
  //* length(mouse.x)

  float ux = u *1.3 - 1.0 + xOffset ;
  float uy = v * 2.0 - 1.0 + mouse.y;

  vec2 xy = vec2(ux, uy) * 1.2;

  float a = 1.-20.*vertexId /vertexCount;

  vec3 color = vec3(a, -a, abs(a));
  color = inv(color);

  gl_Position = vec4(xy, 0.0, 1.0);
  v_color = vec4(color, 1.0);
  gl_PointSize = 40.0;
}