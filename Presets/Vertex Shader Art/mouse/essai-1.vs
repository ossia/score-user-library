/*{
  "DESCRIPTION": "essai",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/nSfY6r4aXmvWBHYyo)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 333,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.23529411764705882,
    0.027450980392156862,
    0.10588235294117647,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 116,
    "ORIGINAL_DATE": {
      "$date": 1587665877326
    }
  }
}*/

void main() {

  float x = sin(time+cos(vertexId));
   float yy = sin(vertexId *- time*1.09);
  float dim = sin(yy-x/yy)+ 24.*x*yy;
  float red = sin(vertexId) * 33.;
  float bleu = sin(vertexId) * 255.;
  float green = asin(vertexId) *5.5;
  gl_Position = vec4(x,1.-mod(yy,dim)*.5,x*0.5,1);
  gl_PointSize = (dim/x)*yy;
    v_color = vec4(mouse.x,1.-bleu,green,0.2);

}