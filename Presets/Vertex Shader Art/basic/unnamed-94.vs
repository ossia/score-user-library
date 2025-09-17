/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/RZLFdeaBCJsCmp6Qg)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 120,
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
    "ORIGINAL_VIEWS": 74,
    "ORIGINAL_DATE": {
      "$date": 1517965137859
    }
  }
}*/

void main ()
{

  float ux = floor(vertexId/ 6.0) + mod(vertexId, 2.0);
  float vy = mod(floor(vertexId / 2.0) + floor(vertexId / 1.0), 2.0);

  float angle = ux/ 20.0 * radians(180.0) * 2.0; //el 20 es como la resolucion convertir, pi radianes por 2( gados de un circulo) , entre 20(ocupar 20 segmentos), lo que necesitas para formar un circulo
  float radius = vy + 1.0; // el radio del circulo es uno, va a ir girando, centro vacio 1
  // ux mas a la derecha , 0, 1 ,2 ,3 ...
  float x =radius * cos(angle);
  float y = radius * sin(angle);

  // x = radius * cos(angle) funcionan en radianes
  // y = radius * sin(angle)

  vec2 xy = vec2(x,y);

  gl_Position = vec4(xy * 0.1, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);

}