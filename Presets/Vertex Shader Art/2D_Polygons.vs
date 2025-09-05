/*{
  "DESCRIPTION": "2D Polygons - Simple polygon generator, just change the number of vertices. This is part of my baby steps in learning GLSL and vertex shaders :)",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/iu7GYL94b7Hm5JyvB)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 5,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1525371455566
    }
  }
}*/

// Simple 2D Polygon generator, after enough vertices are added the geometry resolves to a circle

void main() {
  float radius = 0.5;
  float theta = vertexId / vertexCount * 6.28;

  float z = cos(theta + time);
  float x = cos(theta + time) * radius;
  float y = sin(theta + time) * radius;

  gl_Position = vec4(x, y, z, 1);
  gl_PointSize = 1.0;
  v_color = vec4(vertexId / vertexCount, z, 1.0, 1.0);
}