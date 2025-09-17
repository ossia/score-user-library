/*{
  "DESCRIPTION": "ads",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/95ZMaZireKi2qhi6L)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 7,
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
    "ORIGINAL_VIEWS": 90,
    "ORIGINAL_DATE": {
      "$date": 1536444746716
    }
  }
}*/

void main(){
  float x = floor(vertexId/2.0);
  float y = mod(vertexId, 2.0);

  float angle = x / 20.0 * radians(360.0);
  float radius = y + 1.0;

  float u = radius * cos(angle);
  float v = radius * sin(angle);

  vec2 xy = vec2(u, v) * 0.2;

  gl_Position = vec4(xy, 0.0, 1.0);
  gl_PointSize = 20.0;
  v_color = vec4(1.0, 0.0, 0.5, 1.0);
}