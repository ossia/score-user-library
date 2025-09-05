/*{
  "DESCRIPTION": "essai",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/KAsduiMs3RKWHDcHk)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 247,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 83,
    "ORIGINAL_DATE": {
      "$date": 1584571645179
    }
  }
}*/

void main() {

  float x = sin(time+cos(vertexId));
   float yy = sin(vertexId * time*0.0009);
  float dim = sin(yy+x)+ 4.;
  float red = sin(vertexId) * 255.;
  float bleu = sin(vertexId) * 255.;
  float green = sin(vertexId) * 255.;
  gl_Position = vec4(x,yy,0,1);
  gl_PointSize = (dim);
    v_color = vec4(1,bleu,green,0);

}