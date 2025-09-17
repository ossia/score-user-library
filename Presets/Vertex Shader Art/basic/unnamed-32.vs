/*{
  "DESCRIPTION": "unnamed - tarea4",
  "CREDIT": "dominique (ported from https://www.vertexshaderart.com/art/8bRYb7JjNeomjyGHy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 3000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1518204382115
    }
  }
}*/

vec2 Crear(float vertexId){
  float sqrTotal = floor(sqrt(vertexCount));
  float width = sqrTotal;

  float uxf = floor(vertexId/ 6.0) + mod(vertexId, 2.0);
  float vyf = mod(floor(vertexId / 2.0) + floor(vertexId / 1.0), 2.0);

  float angle = uxf/ 10.0 * radians(180.0) * 2.0; //el 20 es como la resolucion convertir, pi radianes por 2( gados de un circulo) , entre 20(ocupar 20 segmentos), lo que necesitas para formar un circulo
  float radius = vyf + 1.0; // el radio del circulo es uno, va a ir girando, centro vacio 1
  // ux mas a la derecha , 0, 1 ,2 ,3 ...

  float x =radius * cos(angle);
  float y = radius * sin(angle);

  float u = x / (width - 1.0);
  float v = y / (width - 1.0);

  float xOffset = cos(time + y * 0.2) * 0.1;
  float yOffset = cos(time + x * 0.3) * 0.2;

  float uxpri = u * 2.0 - 1.0 + xOffset;
  float vypri = v * 2.0 - 1.0 + yOffset;

  // x = radius * cos(angle) funcionan en radianes
  // y = radius * sin(angle)

  vec2 xy = vec2(uxpri, vypri) * 6.0;
  return xy;
}

void main()
{

  float circulo = floor(vertexId/(20.0*6.0));
  float numeCir = floor(vertexCount / (20.0*6.0));

  float a = floor(sqrt(numeCir));
  float b = floor(numeCir / a);

  float x = mod(circulo, b);
  float y = floor(circulo / b);

  float u = x / (b - 2.0);
  float v = y / (b - 2.0);

  float ux = u * 2.0 - 0.5;
  float vy = v * 2.0 - 0.5;

  vec2 xy = Crear(vertexId) * 0.1 + vec2(ux,vy)*0.7;

  gl_Position= vec4(xy , 0.0, 1.0);
  v_color = vec4(0.0, 1.0, 1.0, 1.0);
}