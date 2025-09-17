/*{
  "DESCRIPTION": "Circle",
  "CREDIT": "alejandrocamara (ported from https://www.vertexshaderart.com/art/pmGvqyPkPbnfcQoLm)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Particles"
  ],
  "POINT_COUNT": 360,
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
      "$date": 1552696880627
    }
  }
}*/

void main()
{
  float x = floor(vertexId / 2.0);
  float y = mod(vertexId + 1.0, 2.0);

  float angle = radians(vertexId);
  float radius = 1.0;

  float u = radius * cos(angle);
  float v = radius * sin(angle);

  vec2 xy = vec2(u, v) * 0.5;

  gl_Position = vec4(xy, 0.0, 1.0);
  gl_PointSize = 1.0;
  /*if (mod(vertexId, 42.0) > 1.0) {
    v_color = vec4(0.0, 0.0, 1.0, 1.0);
  }else if (mod(vertexId, 42.0) == 0.0) {
    v_color = vec4(0.0, 1.0, 1.0, 1.0);
  }*/
  v_color = vec4(0.0, 0.0, 1.0, 1.0);
}