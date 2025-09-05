/*{
  "DESCRIPTION": "Africa",
  "CREDIT": "yuso (ported from https://www.vertexshaderart.com/art/iEqWJsdh8qGqoogEL)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 25914,
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
    "ORIGINAL_VIEWS": 8,
    "ORIGINAL_DATE": {
      "$date": 1551479403333
    }
  }
}*/

/*void main() {

  float width = 20.0;

  float x = floor(vertexId / 2.0);
  float y = mod(vertexId + 1.0, 2.0);

vec2 xy = vec2(x, y) * 0.1;

  //float xOffset = cos(time + y * 0.2) * 0.1;
  //float yOffset = sin(time + x * 0.3) * 0.1;

  //float ux = u * 2.0 - 1.0 + xOffset;
  //float uy = v * 2.0 - 1.0 + yOffset;

  gl_Position = vec4(xy, 0.0, 1.0); // Posición del vector
  v_color = vec4(1.0, 0.0, 1.0, 0.0);
  gl_PointSize = 20.0;

}*/
/*
void main() {

  float width = 20.0;

  float x = floor(vertexId / 2.0);
  float y = mod(vertexId + 1.0, 2.0);

  float u = cos(x -1.);
  float v = cos(y- 1.0);

vec2 xy = vec2(u, v) * 0.1;

  //float xOffset = cos(time + y * 0.2) * 0.1;
  //float yOffset = sin(time + x * 0.3) * 0.1;

  //float ux = u * 2.0 - 1.0 + xOffset;
  //float uy = v * 2.0 - 1.0 + yOffset;

  gl_Position = vec4(xy, 0.0, 1.0); // Posición del vector
  v_color = vec4(1.0, 0.0, 1.0, 0.0);
  gl_PointSize = 20.0;

}*/

void main()
{
  float x = floor(vertexId / 2.0);
  float y = mod(vertexId + 1.0, 2.0);

  float angle = x / 20.0 * radians(360.0);
  float radius = 2.0 - y;

  float u = radius * cos(angle);
  float v = radius * sin(angle);

  vec2 xy = vec2(u, v) * 0.1;

  gl_Position = vec4(xy, 0.0, 1.0);
  gl_PointSize = 20.0;
  v_color = vec4(0.0, 0.0, 0.0, 1.0);
}