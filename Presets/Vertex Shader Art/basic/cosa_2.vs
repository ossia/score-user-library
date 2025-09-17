/*{
  "DESCRIPTION": "cosa 2",
  "CREDIT": "anuar (ported from https://www.vertexshaderart.com/art/S5Zy3N24yyhKqLNwc)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1517961407277
    }
  }
}*/

void main(){

  float ux = floor(vertexId / 6.0) + mod(vertexId, 2.0);
  float vy = mod(floor(vertexId / 2.0) + floor(vertexId/3.0), 2.0);

  float angle = ux / 100.0 * radians(180.0) *2.0;
  float radius = vy +1.0;

  float x = radius* cos(angle);
  float y = radius* sin(angle);

  vec2 xy = vec2(x,y);

gl_Position = vec4(xy*.1, .0, 1.0);
v_color = vec4(1.0,0.0,0.0,1.0);
}