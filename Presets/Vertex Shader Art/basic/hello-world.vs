/*{
  "DESCRIPTION": "hello-world - Messing about",
  "CREDIT": "liaminjapan (ported from https://www.vertexshaderart.com/art/SSfBNBsGgsKWG8SwQ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.12549019607843137,
    0,
    0.3411764705882353,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1508650958083
    }
  }
}*/

void main()
{
  gl_Position = vec4(0,0,0,1);

  gl_PointSize = 10.0;

  v_color = vec4(1,0,0,1);

}