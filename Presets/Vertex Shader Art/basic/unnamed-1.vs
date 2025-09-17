/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/2GcQqCitMWiQ5QRgm)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 3,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.12549019607843137,
    0.10588235294117647,
    0.396078431372549,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 82,
    "ORIGINAL_DATE": {
      "$date": 1499278440282
    }
  }
}*/

void main(){
  gl_PointSize = 10.0;
  gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
}