/*{
  "DESCRIPTION": "first test",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/J6Rbdqdhvx7Yjdh59)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1360,
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
    "ORIGINAL_VIEWS": 50,
    "ORIGINAL_DATE": {
      "$date": 1634511254452
    }
  }
}*/

 void main() {

  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  // float pointSize = 5.;

  float x = mod(vertexId, across);
  float y = floor(vertexId /across);

  float u = x/(across-1.);
  float v = y/(across-1.);

  float xoff = sin(time + y * 0.2) * .1;
  float yoff = sin(time + x * 0.2) * .1;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  gl_Position = vec4(ux,vy,0,1);
  gl_PointSize = 10.;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(1,0,0,1);

}