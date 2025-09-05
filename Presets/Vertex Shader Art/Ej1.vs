/*{
  "DESCRIPTION": "Ej1 - Proyecto 4",
  "CREDIT": "julio (ported from https://www.vertexshaderart.com/art/s3bsdzjr5aaq7n4NR)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 27186,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1552706951577
    }
  }
}*/

void main()
{
  float pointsPerCircle = 42.0;
  float circleAngle = 20.0;
  float circlesPerRow = 25.0;
  float pointsPerRow = pointsPerCircle * circlesPerRow;

  float vertexIdX = floor(mod(vertexId , pointsPerRow) / pointsPerCircle) * 1.3;
  float vertexIdY = floor(vertexId / pointsPerRow) * 1.3;

  float xCircle = floor(vertexId / 2.0);
  float yCircle = mod(vertexId + 1.0, 2.0);

  // Radianes de 360 da 2pi
  float angle = xCircle / circleAngle * radians(360.0);
  float radius = 1.7 - yCircle;

  // Movimiento
  float xOffset = cos(time + vertexIdY * 0.2) * 0.4;
  float yOffset = cos(time + vertexIdX * 0.2 ) * 0.8;

  // Se asignan a 4 cuadrantes
  float uCircle = radius * cos(angle) * 0.3;
  float vCircle = radius * sin(angle) * 0.3;
  float uxCircle = uCircle - (circlesPerRow / 2.0) + xOffset;
  float vyCircle = vCircle - (circlesPerRow / 2.0) + yOffset;

  vec2 xy = vec2(uxCircle + vertexIdX, vyCircle + vertexIdY) * 0.1;

  gl_Position = vec4(xy, 0.0, 1.0);
  gl_PointSize = 1.0;
  v_color = vec4(0.0, 0.7, 1.0, 1.0);
}