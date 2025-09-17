/*{
  "DESCRIPTION": "circulitoTriangleStrip",
  "CREDIT": "vanoog (ported from https://www.vertexshaderart.com/art/LEzaqrf9HzkcvwKea)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100,
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
    "ORIGINAL_VIEWS": 8,
    "ORIGINAL_DATE": {
      "$date": 1551486267798
    }
  }
}*/

void main(){
  float pi = 3.14159;

  float y = mod(vertexId,2.0);
  float x = floor(vertexId/2.0);

  float angle = x / 20.0 * radians(360.0);

  float r = 2.0 - y;

  x = r*cos(angle);
  y = r*sin(angle);

  vec2 xy = vec2(x, y) * 0.1;

  gl_Position = vec4(xy, 0.0, 1.0);
  v_color = vec4(sin(time*x), cos(time*y), cos(x*y), 1.0);

  gl_PointSize = 10.0;
}