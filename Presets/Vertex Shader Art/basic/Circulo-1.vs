/*{
  "DESCRIPTION": "Circulo",
  "CREDIT": "jonaced (ported from https://www.vertexshaderart.com/art/gue44sXxDW5AceuTX)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 802,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.9725490196078431,
    0.9725490196078431,
    0.9725490196078431,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1551488124791
    }
  }
}*/

void main()
{
  float tamCirculo = 400.0;
  float x = floor(vertexId / 2.0);
  float y = mod(vertexId + 1.0, 2.0);

  // Radianes de 360 da pi
  // El 20 son los puntos necesarios para el círculo.
  float angle = x / tamCirculo * radians(360.0);
  float radius = y + 3.0;

  float ux = radius * cos(angle);
  float vy = radius * sin(angle);

  vec2 xy = vec2(ux *abs(cos(time)), vy * abs(sin(time))) * 0.1;
  //vec2 xy = vec2(ux, vy) * 0.1;

  // Donde debería estar el vértice
  gl_Position = vec4(xy, 0, 1.0);
  v_color= vec4(sin(time), cos(time), 1.0, 1.0);
  gl_PointSize = 3.0;
}

/*
void main()
{
  float width = 210.0;
  float x = mod(vertexId, width);
  float y = floor(vertexId / width);
  float line = vertexId/vertexCount;

  float u = x / (width - 1.0);
  float v = y / (width - 1.0);

  float xOffset = cos(time + y * 0.1) * 0.2;
  float yOffset = sin(time + x * 0.1) * 0.2 + 1.0;

  float ux = u * 2.0 - 1.0 + xOffset;
  float vy = v * 2.0 - 1.0 + yOffset;

  // Donde debería estar el vértice
  gl_Position = vec4(ux, vy, sin(time), 1.0);
  // Para color, vector 4
  v_color= vec4(sin(time), cos(time), 1.0, 1.0);

  // Cambiar el tamaño de los puntos
  gl_PointSize = 3.0;

}
*/

/*
Lo del profe
void main()
{
  float width = 20.0;
  float x = mod(vertexId, width);
  float y = floor(vertexId / width);
  float line = vertexId/vertexCount;

  float u = x / (width - 1.0);
  float v = y / (width - 1.0);

  float xOffset = cos(time + y * 0.2) * 0.1;
  float yOffset = sin(time + x * 0.3) * 0.1;

  float ux = u * 2.0 - 1.0 + xOffset;
  float vy = v * 2.0 - 1.0 + yOffset;

  // Donde debería estar el vértice
  gl_Position = vec4(ux, vy, 0, 1.0);
  // Para color, vector 4
  v_color= vec4(sin(time), cos(time), 1.0, 1.0);

  // Cambiar el tamaño de los puntos
  gl_PointSize = 10.0;

}
*/

/*
Triangulo strip 1
void main()
{
  float width = 2.0;
  float x = floor(vertexId / 2.0);
  float y = mod(vertexId + 1.0, 2.0);
  //float y = floor(vertexId / width);

  float u = x / 1.0;
  float v = y / 1.0;

  float tamano = 1.0 / vertexCount;

  float ux = u * 0.1;
  float vy = v * 0.1;

  // Donde debería estar el vértice
  gl_Position = vec4(ux, vy, 0, 1.0);
  // Para color, vector 4
  v_color= vec4(sin(time), cos(time), 1.0, 1.0);

  // Cambiar el tamaño de los puntos
  gl_PointSize = 1.0;

}

*/