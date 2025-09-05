/*{
  "DESCRIPTION": "ejercicio3",
  "CREDIT": "guilleperez (ported from https://www.vertexshaderart.com/art/myzkqKCqtFmmhW5sv)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 62,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1551482552971
    }
  }
}*/

void main()
{
  float width = 10.0;

  //vertexId = 0, 1, 2, 3, 4, 5
  float x = floor(vertexId / 2.0); //0, 0, 1, 1, 2, 2
  float y = mod(vertexId + 1.0, 2.0); //1, 0, 1, 0

  float angle = x / 30.0 * radians(360.0);
  float r = 2.0 - y;

  float u = r * cos(angle);
  float v = r * sin(angle);

  vec2 xy = vec2(u, v) * 0.1; //se puede crear vec4 con vectores 2 -> vec4(xy, 0.0, 1.0);

  gl_Position = vec4(xy, 0.0, 1.0); //position del vec4
  v_color = vec4(1.0, 0.0, 0.0, 1.0); //color
  gl_PointSize = 20.0;
}