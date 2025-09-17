/*{
  "DESCRIPTION": "circuloM",
  "CREDIT": "isa\u00edn (ported from https://www.vertexshaderart.com/art/p7CgySg8MmsZK4MDE)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 83,
  "PRIMITIVE_MODE": "POINTS",
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
      "$date": 1551487188380
    }
  }
}*/

void main(){

  float y = mod(vertexId,2.0);
  float x = floor(vertexId/2.0);

  float angle = x / 20.0 * radians(360.0);

  float r = 2.0 - y;

  float vx = r*cos(angle);
  float vy = r*sin(angle);

  vec2 xy = vec2(vx, vy) * 0.1;

  gl_Position = vec4(xy, 0.0, 1.0);
  v_color = vec4(cos(time*x), sin(time*y), tan(time), 1.0);

  gl_PointSize = 10.0;
}