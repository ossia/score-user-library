/*{
  "DESCRIPTION": "179b",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/6zSLjpCNA7CDQvm9e)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1487059812965
    }
  }
}*/

void main(){float i=vertexId;float t=time;vec2 uv=vec2(cos(i+t)+sin(t*i*.0001),sin(i+t)+sin(t*i*0.0007));gl_Position=vec4(uv*.5,0,1);v_color=vec4(sin(t*i*.001),sin(i+t*.9),1,1);}
