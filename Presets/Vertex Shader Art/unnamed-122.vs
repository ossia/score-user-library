/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "michell (ported from https://www.vertexshaderart.com/art/bN6NWErydKPLz62i5)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 20,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1517961353269
    }
  }
}*/

void main()
{
  float ux = floor(vertexId / 6.0) + mod(vertexId, 2.0);
  float vy = mod(floor(vertexId / 2.0) + floor(vertexId / 3.0), 2.0);

  float angle = ux / 20.0 * radians(180.0) * 2.0;
  float radius = vy + 1.0;

  float x = radius * cos(angle);
  float y = radius * sin(angle);

  // x = radius * cos(angle);
  // y = radius * sin(anlge);

  vec2 xy = vec2(x,y);

  gl_Position = vec4(xy *0.1, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
}