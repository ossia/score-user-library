/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "benjamin (ported from https://www.vertexshaderart.com/art/6t7WhmEDeF7kcGFDh)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 34504,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0.5019607843137255,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1516799751442
    }
  }
}*/



void main() {
   float across = 7.;

 float x = mod(vertexId, across);
    float y = floor(vertexId / across);

   float u = x / 10.;
    float v = y / 10.;

    gl_Position = vec4(u, v, 0, 1.0);
   v_color = vec4(1,0,0,1);

}
