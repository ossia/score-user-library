/*{
  "DESCRIPTION": "FirstShader - My first shader :O",
  "CREDIT": "\u05d0\u05e8\u05d3 (ported from https://www.vertexshaderart.com/art/FJRdnZn9mERmk9Yaz)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Particles"
  ],
  "POINT_COUNT": 4784,
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
    "ORIGINAL_VIEWS": 184,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1575397945452
    }
  }
}*/

void main() {

  float across = floor(sqrt(vertexCount));

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  float default_point_size = (300. / across) * (resolution.x / 600.);

  float size = default_point_size * (sin(ux * 20.) * cos(vy * 20.));

  gl_PointSize = abs(size);

  gl_Position = vec4(ux, vy, 0, 1);

  v_color = vec4(size, 0, 1. - size, 1.);
}