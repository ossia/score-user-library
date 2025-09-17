/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/sYBECGM9gRBccnwPb)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 1,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.6235294117647059,
    0.6235294117647059,
    0.6235294117647059,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 94,
    "ORIGINAL_DATE": {
      "$date": 1532765295139
    }
  }
}*/

void main()
{
 gl_PointSize = 10.0;

   vec2 xy = vec2(vertexId / 3.0, vertexId / 3.0);

   gl_Position = vec4(xy, 0.0, 1.0);
   v_color = vec4(0.0, 0.0, 0.0, 1.0);
}