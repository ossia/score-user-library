/*{
  "DESCRIPTION": "Vertex Shader Art Lesson 1 - This stuff is quite tough",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/jaG2f5XtrcpcNSePf)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Abstract"
  ],
  "POINT_COUNT": 100,
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
      "$date": 1524505337363
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

  float ux = u * 2.0 - 1.0; // gets value from -1 to 1
  float uy = v * 2.0 - 1.0; // gets value from -1 to 1

  gl_Position = vec4(ux, uy, 0.0, 1.0);

  gl_PointSize = 200.0 / across; // set point size
  gl_PointSize *= resolution.x / 600.0;

  v_color = vec4(1.0, 0, 0, 1); // this is unique to vertex shader art
}