/*{
  "DESCRIPTION": "points,lines, and triangles. Its all pretty. - Try points, lines, and triangles.",
  "CREDIT": "vincent (ported from https://www.vertexshaderart.com/art/TAL5yA4piTpRpG2Qw)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 4000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 122,
    "ORIGINAL_DATE": {
      "$date": 1451340637158
    }
  }
}*/

void main()
{
  float x = (vertexId/1000.0) - 1.0;
  float sign = mod( vertexId, 2.0 ) * 2.0 - 1.0;
  float y = x * sign;
  gl_Position = vec4(x,y,0,1);
  gl_PointSize = (10.0 * x) * (x * 10.0) + 10.0;
  v_color = vec4(x * 10.0 * x * 2.0 + 1.0,
        x*x*x*x,
        x * x * 2.0 - 1.0,
        1.0);
}

