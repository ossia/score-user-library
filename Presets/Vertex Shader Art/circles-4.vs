/*{
  "DESCRIPTION": "circles",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/TZ58peuETd4DLzbYC)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 1920,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 157,
    "ORIGINAL_DATE": {
      "$date": 1518199794084
    }
  }
}*/


vec2 createCircle(float vertexId){
  float ux = floor(vertexId / 6.0) + mod(vertexId, 2.0);
  float vy = mod(floor(vertexId / 2.0) + floor (vertexId /3.0), 2.0);

  float angle = ux /20.0 * radians(180.0) * 2.0;
  float radius = vy + 1.0;

  float x = radius * cos(angle);
  float y = radius * sin(angle);

  vec2 xy = vec2(x,y);
  return xy;
}

void main()
{

  float circleId = floor(vertexId/(20.0*6.0));
  float numCircles = floor(vertexCount / (20.0*6.0));

  float down = floor(sqrt(numCircles));
  float across = floor(numCircles / down);

  float x = mod(circleId, across);
  float y = floor(circleId / across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float ux = u * 2.0 - 1.0;
  float vy = v * 2.0 - 1.0;

  vec2 xy = createCircle(vertexId) * 0.1 + vec2(ux,vy)*0.7;

  gl_Position= vec4(xy , 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
}