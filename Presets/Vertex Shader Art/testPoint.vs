/*{
  "DESCRIPTION": "testPoint",
  "CREDIT": "codework10101 (ported from https://www.vertexshaderart.com/art/etLPNmJ9oBq9QDcz6)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.25098039215686274,
    0.5019607843137255,
    0.5019607843137255,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1544373611343
    }
  }
}*/

void main()
{

  float down = floor( sqrt( vertexCount ) );
  float across = floor( vertexCount / down );

  float index = vertexId;
  float x = mod(index, across);
  float y = floor(index/across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float ux = u * 2.0 - 1.0;
  float vy = v * 2.0 - 1.0;

  gl_Position = vec4(ux, vy, 0.0, 1.0);

  gl_PointSize = 10.0;
  gl_PointSize *= 20.0 / across;

  gl_PointSize *= resolution.x / 600.0;

  v_color = vec4(1, 0, 0, 1);
}