/*{
  "DESCRIPTION": "My programing class",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/uBNYQJxs6ta546Y5j)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 3923,
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
    "ORIGINAL_VIEWS": 60,
    "ORIGINAL_DATE": {
      "$date": 1524834723669
    }
  }
}*/

void main()
{
  float width = floor(sqrt(vertexCount-8.));

  float x = mod(vertexId*0.5, width);
  float y = floor(vertexId / width/6.);

  float u = x / (width - 1.0);
  float v = y / (width - .6);

  float xOffset = cos(time + y * 10.2) * 0.1;
  float yOffset = cos(time + x * 1.3) * 0.3;

  float ux = u * 2.0 - 1.35 -sin(time)+ xOffset;
  float vy = v * 5.0 / (time *0.3) + yOffset;

  //vertexId 0 1 2 ... 10 11 12 13 ... 20 21 22
  //mod 0 1 2 ... 0 1 2 3 ... 0 1 2 (residuo) X
  //floor 0 0 0 ... 1 1 1 1 ... 2 2 2 (divididos) Y

  vec2 xy = vec2(ux, vy) * (2.2-sin(time/x-3.));

  gl_Position = vec4 (xy, 0.25, 1.0);

  float sizeOffset = sin(time + x * y * 0.712) * 17.0;
  gl_PointSize = 10.0 + sizeOffset;
  gl_PointSize *= 3.0 / width/6.;

  v_color= vec4(0.5, .22, (x *sin(y-time*0.6)-y), 0.2);
}