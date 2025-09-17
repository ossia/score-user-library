/*{
  "DESCRIPTION": "study01",
  "CREDIT": "junkyo (ported from https://www.vertexshaderart.com/art/wrTE6KKesztAX6apx)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.08627450980392157,
    0.043137254901960784,
    0.10588235294117647,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1531285632829
    }
  }
}*/

void main(){

  float across = 10.;

  float x = mod(vertexId,across);
  float y = floor(vertexId / across);

  float u = x / across;
  float v = y / across;

  gl_Position = vec4(u, v, 0, 1);

  gl_PointSize = 10.0;

  v_color = vec4(1,0,0,1);

}