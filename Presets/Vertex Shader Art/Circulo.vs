/*{
  "DESCRIPTION": "Circulo - Primera",
  "CREDIT": "julio (ported from https://www.vertexshaderart.com/art/cYx2ofpAnLZMY6Xqr)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 72,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    0.9921568627450981,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1551490687950
    }
  }
}*/

void main()
{
   float x = floor(vertexId / 2.0);
   float y = mod(vertexId + 1.0, 2.0);

   float angle = x / 20.0 * radians(360.0);
   float radius = 2.0 - y;

  float ux = radius * cos(angle);
  float uy = radius * sin(angle);

  vec2 xy = vec2(ux, uy) * 0.1;

 gl_Position = vec4(xy, 0.0, 1.0);
    v_color = vec4(sin(angle), cos(radius), sin(time), 1.0);
    gl_PointSize = 10.0;
}

/*void main()
{
   float pi = 3.141592;
   float x = vertexId / 20.0 * 2.0 * pi;
   float y = vertexId / 20.0 * 2.0 * pi;
   float r = mod(vertexId, 2.0) + (y * 0.1);

   float ux = r * cos(x) * 0.1;
   float uy = r * sin(y) * 0.1;

 gl_Position = vec4(ux, uy, 0.0, 1.0);
    v_color = vec4(1.0, 0.0, 0.0, 1.0);
    gl_PointSize = 10.0;
} */

/*void main()
{
   float x = floor(vertexId / 2.0) * 0.1;
   float y = (vertexId + 1.0 - floor(vertexId / 2.0)) * 0.1;
 gl_Position = vec4(x, y, 0.0, 1.0);
    v_color = vec4(1.0, 0.0, 0.0, 1.0);
    gl_PointSize = 10.0;
}*/

/*void main()
{
   float x = floor(vertexId / 2.0) * 0.1;
   float y = mod(vertexId + 1.0, 2.0) * 0.1;
 gl_Position = vec4(x, y, 0.0, 1.0);
    v_color = vec4(1.0, 0.0, 0.0, 1.0);
    gl_PointSize = 10.0;
} */

/* void main()
  {
      float width = 20.0;
      float x = mod(vertexId, width);
      float y = floor(vertexId / width);

      float u = x / (width - 1.0);
      float v = y / (width - 1.0);

      float xOffset = sin(time + y * 0.1) * 0.5;
      float yOffset = cos(time + x * 0.4) * 0.3;

      float ux = u * 2.0 - 1.0 + xOffset;
      float vy = v * 2.0 - 1.0 + yOffset;

      vec2 xy = vec2(ux, vy) * 0.5;

      gl_Position = vec4(ux, vy, sin(time), 1.0);
      v_color = vec4(sin(time / vertexId), sin(time), cos(vertexId), 1.0);
      gl_PointSize = 40.0;
  }*/