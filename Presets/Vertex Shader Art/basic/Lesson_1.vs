/*{
  "DESCRIPTION": "Lesson 1",
  "CREDIT": "soumak (ported from https://www.vertexshaderart.com/art/DCrDjahDxMww73hcZ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
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
      "$date": 1640454775874
    }
  }
}*/

void main() {
  float accross = floor(sqrt(vertexCount));
  float x = mod(vertexId, accross);
  float y = floor(vertexId/ accross);

  float u = x / (accross-1.) * 2. - 1.;
  float v = y / (accross-1.) * 2. - 1.;

  gl_Position = vec4(u,v,0,1);
  gl_PointSize = 10.0;
  gl_PointSize *= 20. / accross;
  v_color = vec4(1,0,0,1);
}