/*{
  "DESCRIPTION": "Making A Grid_minseok_kim",
  "CREDIT": "minseok.kim (ported from https://www.vertexshaderart.com/art/WC5fhEkctfmHrGz6m)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 4203,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1684323718468
    }
  }
}*/

//Name : minseok kim
//Assignment : Exercise - Vertexshaderart : Making a Grid
//Course : CS250
//Term : Spring 2023

void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across-1.);
  float v = y / (across-1.);

  float ux = u * 2. -1.;
  float vy = v * 2. -1.;

  float utime = time;

  gl_Position = vec4(ux,vy,0,1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20.0 / across;

  gl_PointSize *= resolution.x / 600.0;

  v_color = vec4(cos(utime),sin(utime),1,1);

}
