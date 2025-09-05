/*{
  "DESCRIPTION": "omg",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/nyGuXdDQvXKEPcSGJ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 46,
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
    "ORIGINAL_VIEWS": 92,
    "ORIGINAL_DATE": {
      "$date": 1551486952223
    }
  }
}*/

void main()
{

  float x = floor(vertexId / 2.0);
  float y = mod(vertexId + 1.0, 2.0);

  float angle = (x/20.0) * radians(360.0);
  float r = 2.0 - y;

   float ux = r * cos(angle)*0.2;
   float uy = r * sin(angle)*0.2;

  //float xOffset = cos(17.0 + x) + sin(70.0 + y) * 0.1;
  //float yOffset = cos(-6.0 + y) + sin(93.0 + x) * 0.1;

  gl_Position = vec4(ux, uy, 0.0 , 1.0);
  v_color = vec4(cos(time * x), sin(time * y), tan(time), 1.0);
  gl_PointSize = 10.0;

}