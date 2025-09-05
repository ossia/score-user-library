/*{
  "DESCRIPTION": "Grid",
  "CREDIT": "alejandrocamara (ported from https://www.vertexshaderart.com/art/JhPkQF3eX4q9YcDML)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 742,
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
      "$date": 1552697032471
    }
  }
}*/

void main()
{
   // Distancia entre los puntos
   // y numero de puntos por fila
   float width = 10.0;

   // Ubicacion de los circulos
   float x = mod(vertexId, width); // Columna
   float y = floor(vertexId / width); // Fila

   // Escala de los puntos para que quepan en la pantalla
   float u = x / (width - 1.0);
   float v = y / (width - 1.0);

   // Movimiento en onda
   float xOffset = sin(time + y * 0.2) * 0.1;
   float yOffset = cos(time + x * 0.3) * 0.2;

   //float xOffset = 0.0;
   //float yOffset = 0.0;

   // Coordenadas finales
   float ux = u * 2.0 - 1.0 + xOffset;
   float vy = v * 2.0 - 1.0 + yOffset;

   vec2 xy = vec2(ux, vy) * 1.2;

 gl_Position = vec4(xy, 0.0, 1.0);
   v_color = vec4(1.0, 0.0, 0.0, 1.0);
   gl_PointSize = 20.0;
}