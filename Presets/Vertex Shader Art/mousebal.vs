/*{
  "DESCRIPTION": "mousebal",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/wt7dgJfnc9ut9a8tk)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 472,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1524355193825
    }
  }
}*/

void main() {
  float v=vertexId/30.0;
  int num=int(mouse.x*10.0+10.0);
  int den=int(exp(mouse.y*3.0+3.0));
  float frac=1.0-float(num)/float(den);
  vec2 xy=vec2(sin(v),cos(v)*sin(v*frac))/2.0;
  vec2 aspect = vec2(1, resolution.x / resolution.y);
  gl_Position = vec4(xy * aspect, 0, 1);
  v_color = vec4(0,0,0, 1);
}