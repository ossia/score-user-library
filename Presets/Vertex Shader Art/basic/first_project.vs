/*{
  "DESCRIPTION": "first project",
  "CREDIT": "ninja (ported from https://www.vertexshaderart.com/art/RNvmyLxwWoWWorb59)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 74709,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.3333333333333333,
    0.3333333333333333,
    0.3333333333333333,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 151,
    "ORIGINAL_DATE": {
      "$date": 1595224776485
    }
  }
}*/

void main()
{

  float x = mod(vertexId,10.0);
  float y = ceil(vertexId/10.0) * vertexCount/123123.0;

  float u = x/10.0;
  float v = y/10.0;

  gl_Position = vec4(u - 0.5 ,v - 0.5 ,0,1);
  gl_PointSize = 10.0;

  v_color = vec4(1,0,0,1);
}