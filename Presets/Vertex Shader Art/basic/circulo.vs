/*{
  "DESCRIPTION": "circulo",
  "CREDIT": "isa\u00edn (ported from https://www.vertexshaderart.com/art/AA2EgkaRKHJ5g74i5)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 4608,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.8392156862745098,
    0.9450980392156862,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1551486989870
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