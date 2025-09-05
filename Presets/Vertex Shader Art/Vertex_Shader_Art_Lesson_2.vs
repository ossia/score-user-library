/*{
  "DESCRIPTION": "Vertex Shader Art: Lesson 2 - Modelling motion",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/SvkxzENQ5fAgKSxZp)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Abstract"
  ],
  "POINT_COUNT": 1000,
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1524509346653
    }
  }
}*/

void main() {
  float down = floor(sqrt(vertexCount)); // gets the count of rows
  float across = floor(vertexCount / down); // gets the count of columns

  // vertexId is the
  float x = mod(vertexId, across); // always use floats
  float y = floor(vertexId / across); // rounds numbers down 0.1 = 0, 10 = 1

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float xOffset = sin(time + y * 0.2) * 0.1;
  float yOffset = sin(time + x * 0.3) * 0.2;

  float ux = u * 2.0 - 1.0 + xOffset; // gets value from -1 to 1
  float uy = v * 2.0 - 1.0 + yOffset; // gets value from -1 to 1

  vec2 xy = vec2(ux, uy) * 1.25;

  float sizeOffset = sin(time + x * y * 0.02) * 3.0;

  gl_Position = vec4(xy, 0.0, 1.0);
  gl_PointSize = 200.0 / across; // set point size
  gl_PointSize *= resolution.x / 600.0 + sizeOffset;

  v_color = vec4(1.0, 0.0, 0.0, 1); // this is unique to vertex shader art
}