/*{
  "DESCRIPTION": "Making a Grid seongwon Jang",
  "CREDIT": "seongwon.jang (ported from https://www.vertexshaderart.com/art/v8Q2uDoFCSfa5sQRC)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1000,
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
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1652841655383
    }
  }
}*/

void main() {
  float down = sqrt(vertexCount);
  float across = floor(vertexCount / down);
  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux - sin(time + vy) + 0.5, vy + cos(time * ux + vy) - 0.5,cos(time + vy + ux), 1);
  gl_PointSize = 15.0;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;

  v_color = vec4(gl_Position.x, gl_Position.y, gl_Position.z, 1);
}