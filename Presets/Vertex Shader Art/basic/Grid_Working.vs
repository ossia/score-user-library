/*{
  "DESCRIPTION": "Grid Working",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/eiQJGkMsgvxpx6Ejq)",
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
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1494931026482
    }
  }
}*/



void main(){
  float across = 10.;

  float x = mod(vertexId, across );
  float y = floor(vertexId / across);

  float u = x / (across -1.);
  float v = y / (across -1.);

  float ux = u * 2. -1.;
  float vy = v * 2. -1.;

  gl_Position = vec4(ux,vy,0,1);

  gl_PointSize = 10.0;

  v_color = vec4(1,0,0,1);

}