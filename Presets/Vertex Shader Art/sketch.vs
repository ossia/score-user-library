/*{
  "DESCRIPTION": "sketch",
  "CREDIT": "chriscamplin (ported from https://www.vertexshaderart.com/art/WbN969kWgnCsYXofi)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 14,
    "ORIGINAL_DATE": {
      "$date": 1676886843571
    }
  }
}*/

void main() {
  float v=vertexId/30.0;
  int num=int(mouse.x*10.0+10.0);
  int den=int(exp(mouse.y*3.0+3.0));
  float frac=1.0-float(num)/float(den);
  vec2 xy=vec2(sin(v),cos(v)*sin(v*frac))/2.0;
  for(int i = 0; i < 2; i++) {
    xy*=abs(xy)/dot(xy, xy)-vec2(frac);
  }
  vec2 aspect = vec2(1, resolution.x / resolution.y);
  gl_Position = vec4(xy * aspect, 0, 1);
  v_color = vec4(0,0,0, 1);
}