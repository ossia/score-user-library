/*{
  "DESCRIPTION": "ejercicio2",
  "CREDIT": "guilleperez (ported from https://www.vertexshaderart.com/art/jDrqfnTPaPAoShgv2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 15,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1551482560589
    }
  }
}*/

void main()
{
  float width = 10.0;

  //vertexId = 0, 1, 2, 3, 4, 5
  float x = floor(vertexId / 2.0); //0, 0, 1, 1, 2, 2
  float y = mod(vertexId + 1.0, 2.0); //1, 0, 1, 0

  vec2 xy = vec2(x, y) * 0.1;

  gl_Position = vec4(xy, 0.0, 1.0); //position del vec4
  v_color = vec4(1.0, 0.0, 0.0, 1.0); //color
  gl_PointSize = 20.0;
}