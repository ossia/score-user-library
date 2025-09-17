/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "michell (ported from https://www.vertexshaderart.com/art/hx9o8G4NbrqkXa8dd)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 3567,
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
      "$date": 1518145136543
    }
  }
}*/

vec2 getCircle(float id)
{

  float uxc= floor(id / 6.0) + mod(id, 2.0);
  float vyc = mod(floor(id / 2.0) + floor(id / 3.0), 2.0);

  float angle = uxc / 20.0 * radians(180.0) * 2.0; //20 segmentos
  float radius = vyc + 1.0;

  float xc = radius * cos(angle);
  float yc = radius * sin(angle);

  return vec2(xc, yc);
}

void main()
{

  vec2 circleXY = getCircle(vertexId);

  float circleId = floor(vertexId / 120.0);
  float circleCount = floor(vertexCount / 120.0);

  float sqrTotal = floor(sqrt(circleCount));
  float width = sqrTotal;

  float x = mod(circleId, width);
  float y = floor(circleId / width);

  float u = x / (width - 1.0) ;
  float v = y/ (width - 1.0) ;

  float ux = u * 2.0 - 1.0 ;
  float vy = v * 2.0 - 1.0 ;

  vec2 xy = circleXY * 0.1 + vec2( ux, vy);

  gl_Position = vec4(xy, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);

}