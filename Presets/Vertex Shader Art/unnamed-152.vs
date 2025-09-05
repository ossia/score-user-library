/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/jjpd8XtJ5nJAcmyLh)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
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
    "ORIGINAL_VIEWS": 75,
    "ORIGINAL_DATE": {
      "$date": 1551480117897
    }
  }
}*/

void main()
{
  float width = 10.0;
  float x = mod(vertexId, width) * 0.05;
  float y = floor(vertexId / width) * 0.05;

  float u = x / (width - 1.0);
  float v = y / (width - 1.0);

  gl_Position = vec4(u, v, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
  gl_PointSize = 10.0;
}

