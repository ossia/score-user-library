/*{
  "DESCRIPTION": "circulos",
  "CREDIT": "marcoisaac (ported from https://www.vertexshaderart.com/art/A9X62RRorFW5Ys8h7)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 2638,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1552710516163
    }
  }
}*/

vec2 drawCircleXY(float id);

void main()
{

  float circleCount = floor(vertexCount / 360.0);
  float circleId = floor(vertexId / 120.0);

  float sqrTotal = floor(sqrt(circleCount));
  float width = sqrTotal;

  float x = mod(circleId, width); // [0, width - 1]
  float y = floor(circleId / width); // [0, inf]

  float angle = x / 20.0 * radians(180.0) * 2.0 ;
  float radius = y + 1.0;

  float u = radius * cos(angle);
  float v = radius * sin(angle);

  float xOffset = cos(time * 2.0) * 0.2 ;
  float yOffset = cos(time * 3.0) * 1.0 ;

  float ux = u * 2.0 - 1.0 + xOffset;
  float vy = v * 2.0 - 1.0 + yOffset;

  vec2 xy = vec2(ux, vy)* 0.4;
  //vec2 xyy = vec2(ux, vy);

  gl_Position = vec4(xy + (drawCircleXY(vertexId) * 0.05) , 0.0, 1.0);

  gl_PointSize = 15.0 ;
  gl_PointSize *= 32.0 / width;
  v_color = vec4(1.0, 0.0, 0.0, 1.0);

}

vec2 drawCircleXY(float id)
{

  float x = floor(id / 6.0) + mod(id, 2.0);
  float y = mod(floor(id / 2.0) + floor(id / 3.0), 2.0);

  float angle = x / 20.0 * radians(180.0) * 2.0 ;
  float radius = y + 1.0;

  float u = radius * cos(angle);
  float v = radius * sin(angle);

  vec2 xy = vec2(u, v);

  return xy;
}