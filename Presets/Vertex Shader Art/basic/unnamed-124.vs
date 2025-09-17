/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "aphim44 (ported from https://www.vertexshaderart.com/art/cxdd3QwD34CZzTpFj)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 40,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.7803921568627451,
    0.5568627450980392,
    0.5568627450980392,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1699414242999
    }
  }
}*/

void main(){
  float act = resolution[1]/resolution[0];

  v_color = vec4(0.0, 0.0, 0.0, 1.0);
  gl_PointSize = 5.0;

  float x = floor(vertexId / 2.0);
  float y = mod(vertexId +1., 2.0);

  float elements = x / 100.0;
  float angle = elements * radians(360.0);
  float radius = 4. - y;

 x = radius * cos(angle);
  y = radius * sin(angle);

  vec2 xy = vec2(x, y) * 0.1;
  xy[0]*=act;
// xy[0]*=cos(10.);
  //xy[1]*=sin(10.);

  gl_Position = vec4(xy, 0.0, 1.0);
}
