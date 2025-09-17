/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "jc (ported from https://www.vertexshaderart.com/art/Rfe9EhWQ5Pe2SD9JR)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 16384,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.7803921568627451,
    0.7843137254901961,
    0.803921568627451,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1517973837241
    }
  }
}*/

void circle()
{
  float xC = floor(vertexId / 6.0) + mod(vertexId, 2.0);
  float yC = mod(floor(vertexId / 2.0) + floor(vertexId / 3.0), 2.0);

  float angle = xC / 20.0 * radians(180.0) * 2.0;
  float radius = yC + 1.0;

  float xPC = radius * cos(angle);
  float yPC = radius * sin(angle);

  vec2 xyPC = vec2(xPC,yPC);

  gl_Position = vec4(xyPC * 0.1, 0.0, 1.0);
}

void main()
{

  float width = floor(sqrt(vertexCount));

  float x = mod(vertexId, width);
  float y = floor(vertexId / width);

  float u = x / (width);
  float v = y / (width);

  float ux = u * 2.0 - 1.0;
  float vy = v * 2.0 - 1.0;

  vec2 xy = vec2(ux, vy) * 1.0;

  gl_Position = vec4 (xy, 0.0, 1.0);

  gl_PointSize = 10.0;
  gl_PointSize *= 32.0 / width;

  v_color= vec4(0.0, 1.0, 0.0, 1.0);

}