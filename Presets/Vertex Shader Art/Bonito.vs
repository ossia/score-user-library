/*{
  "DESCRIPTION": "Bonito",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/DMsF68oEXEH2wGgAT)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 19328,
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
    "ORIGINAL_VIEWS": 67,
    "ORIGINAL_DATE": {
      "$date": 1517618882909
    }
  }
}*/


void main()
{
  float width = floor(sqrt(vertexCount));

  float x = mod(vertexId,width);
  float y = floor(vertexId/width);

  float u = x/(width-1.0);
  float v = y/(width-1.0);

  float xOffset = cos(time+ y * 0.2)* 0.1;
  float yOffset = cos(time + x * 0.3)* 0.2;

  float ux = u * 2.0 - 1.0 + xOffset;
  float vy = v * 2.0 - 1.0 +yOffset;

  // mod 0 1 2 3 4 5 .... 0 1 2 3 .... 0 1 2 3
  // vertexId 0 1 2 3 4 5.... 10 11 12 13 ... 20 21 22
  // floor 0 0 0 0 0 .... 1 1 1 1 .... 2 2 2 2

  gl_Position = vec4(ux,vy,0.0,1.0);
  float sizeOffset = sin(time+x*y*0.02)*5.0;
  gl_PointSize = 5.0+sizeOffset;
  gl_PointSize = 32.0/width;
  v_color = vec4(1.0,1.0,1.0,1.0);

}