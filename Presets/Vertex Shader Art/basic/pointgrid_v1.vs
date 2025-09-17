/*{
  "DESCRIPTION": "pointgrid v1",
  "CREDIT": "chrisbartholomew (ported from https://www.vertexshaderart.com/art/Fx9jpEFb8X6WPRBT9)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 245,
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
      "$date": 1544316739041
    }
  }
}*/

void main(){
  float horiz = floor(sqrt(vertexCount));
    float vertic = floor(sqrt(vertexCount)) ;
 float x = mod(vertexId, horiz);
  float y = floor(vertexId / vertic);

  float u = x / (horiz - 1.) ;
  float v = y / (vertic - 1.) ;

  float ux = u * 2. - 1. ;
  float vy = v * 2. - 1. ;

  gl_Position = vec4(ux, vy, 0, 1);
  gl_PointSize = floor(sqrt(vertexCount));
  v_color = vec4(1, 0, 0, 1);
}

