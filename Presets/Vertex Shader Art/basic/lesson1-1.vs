/*{
  "DESCRIPTION": "lesson1",
  "CREDIT": "mhorga (ported from https://www.vertexshaderart.com/art/LrWhYy7j7kZTWy5FC)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 2000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0.17647058823529413,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1499274917770
    }
  }
}*/

// circles made of triangles - try > 2000 vertices for smooth edge
void main() {
  float x = floor(vertexId / 6.) + mod(vertexId, 2.);
  float y = mod(floor(vertexId / 2.) + floor(vertexId / 3.), 2.);
  float s = sin(x);
  float c = cos(x);
  float radius = y + 1.;
  x = s * radius;
  y = c * radius;
  vec2 xy = vec2(x, y);
  gl_Position = vec4(xy * 0.1, 0, 1);
  v_color = vec4(1, 0 , 0, 1);
}

#if 0

// a mesh made out of triangles (switch to Triangles primitive)
void main() {
  float x = floor(vertexId / 6.) + mod(vertexId, 2.);
  float y = mod(floor(vertexId / 2.) + floor(vertexId / 3.), 2.);
  vec2 xy = vec2(x, y);
  gl_Position = vec4(xy * 0.1, 0, 1);
  v_color = vec4(1, 0 , 0, 1);
}

// a grid made of points (switch to using Points primitive)
void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);
  float x = mod(vertexId, across) / (across - 1.);
  float y = floor(vertexId / across) / (across - 1.);
  float u = x * 2. - 1.;
  float v = y * 2. - 1.;
  gl_Position = vec4(u, v, 0, 1);
  gl_PointSize = 10.;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;
  v_color = vec4(1, 0 , 0, 1);
}

#endif
