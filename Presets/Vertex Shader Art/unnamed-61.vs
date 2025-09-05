/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/G44HeacsoBQDo4MFC)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0.25098039215686274,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 37,
    "ORIGINAL_DATE": {
      "$date": 1476361456912
    }
  }
}*/

void main(){
  float across = 10.;

  float x = mod(vertexId , across);
  float y = floor(vertexId / across);

  float u = x / across;
  float v = y / across;

   gl_Position = vec4(u,v,0,1);
  gl_PointSize = 10.0;
  v_color = vec4(1,0,0,1);
}