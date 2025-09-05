/*{
  "DESCRIPTION": "P04-Ej01",
  "CREDIT": "alejandrocamara (ported from https://www.vertexshaderart.com/art/vhbgo3kHochQMeb2i)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 4200,
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
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_DATE": {
      "$date": 1552970081941
    }
  }
}*/

#define CIRCLE_SEGMENTS 20.0
#define PRIMITIVE_COUNT 42.0
#define TWO_PI radians(360.0)

void main() {

   float normalized_id = mod(vertexId, PRIMITIVE_COUNT);

   float circle_x = floor(normalized_id / 2.0);
    float circle_y = mod(normalized_id + 1.0, 2.0);

    float angle = circle_x / CIRCLE_SEGMENTS * radians(360.0);
    float radius = 2.0 - circle_y;

    float circle_u = radius * cos(angle);
    float circle_v = radius * sin(angle);

    vec2 circle_xy = vec2(circle_u, circle_v) * 0.05;

   // Distancia entre los puntos
   // y numero de puntos por fila
   float width = 10.0;

   // Ubicacion de los circulos
   float x = mod(floor(vertexId / PRIMITIVE_COUNT), width); // Columna
   float y = floor(((vertexId / (PRIMITIVE_COUNT) )/ width)); // Fila

   // Escala de los puntos para que quepan en la pantalla
   float u = x / (width - .50);
   float v = y / (width - .50);

   // Movimiento en onda
   float xOffset = sin(time + y * 0.2) * 0.1;
   float yOffset = cos(time + x * 0.3) * 0.2;

   //float xOffset = 0.0;
   //float yOffset = 0.0;

   // Coordenadas finales
   float ux = u * 2.0 - 1.0 + xOffset;
   float vy = v * 2.0 - 1.0 + yOffset;

   vec2 xy = vec2(ux, vy) * 1.2;

   // xy = vec2(x, y) / 5.0;

 gl_Position = vec4(circle_xy + xy, 0.0, 1.0);
   v_color = vec4(1.0, 0.0, 0.0, 1.0);
   gl_PointSize = 5.0;
}