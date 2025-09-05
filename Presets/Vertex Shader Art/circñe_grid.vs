/*{
  "DESCRIPTION": "circ\u00f1e_grid",
  "CREDIT": "marcoisaac (ported from https://www.vertexshaderart.com/art/HS9sJXXJGFwxGjoYe)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 28107,
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1553480227797
    }
  }
}*/

vec2 drawCircle(float id);

void main()
{

  float circleId = floor(vertexId / 120.0);
  float numCircles = floor(900.0 / 5.0);

  float col = floor(sqrt(numCircles));//down
  float fil = floor(numCircles/col);//across

  float x = mod(circleId, fil); // [0, width - 1]
  float y = floor(circleId / fil); // [0, inf]

  float u = x / (fil - 1.0);
  float v = y / (fil - 1.0);

  float xOffset = cos(time + y * 0.2) * 0.3;
  float yOffset = cos(time + x * 0.3) * 0.3 ;

  float ux = u * 2.0 - 1.0 + xOffset;
  float vy = v * 2.0 - 1.0 + yOffset;

  //vec2 xy = vec2(ux, vy)* 0.4;
  vec2 xy = drawCircle(vertexId) * 0.16 + vec2(ux, vy) * 1.5;

  //gl_Position = vec4(xy + (drawCircleXY(vertexId) * 0.05) , 0.0, 1.0);
  gl_Position = vec4(xy, 0.0, 1.0);

  gl_PointSize = 15.0 ;
  gl_PointSize *= 32.0 / fil;
  v_color = vec4(1.0, 0.0, 0.0, 1.0);

}

vec2 drawCircle(float id)
{

  float x = floor(id / 2.0) + mod(id, 2.0);
  //float y = mod(floor(id / 2.0) + floor(id / 3.0), 2.0);
  float y = mod(id + 1.0, 2.0);

  float angle = x / 20.0 * radians(180.0) * 2.0 ;
  float radius = 2.0 - y;

  float u = radius * cos(angle);
  float v = radius * sin(angle);

  vec2 xy = vec2(u, v) * 0.33;

  return xy;
}