/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/YgBq9NXqcsYsRmpBe)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 168,
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
    "ORIGINAL_VIEWS": 81,
    "ORIGINAL_DATE": {
      "$date": 1552678010010
    }
  }
}*/

/********Ejecicio #1 *********/
/*void main(){
//Vector 4
  float width = 20.0;

  float x = mod(vertexId, width);
  float y = floor(vertexId / width);

  float u = x / (width - 1.0);
  float v = y / (width - 1.0);

  float xOffset = cos(time + y * 0.2) * 0.1;
  float yOffset = sin(time + x * 0.3) * 0.1;

  float ux = u * 2.0 -1.0 + xOffset;
  float uy = v * 2.0 -1.0 + yOffset;

  vec2 xy = vec2(ux, uy) * 1.2;

  gl_Position = vec4(ux, uy, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
  gl_PointSize = 10.0;
}
*/

void main(){
//Vector 4
  float width = 20.0;

  float y = mod(vertexId + 1.0, 2.0);
  float x = floor(vertexId / 2.0);
  float ang = (x/20.0)*radians(360.0);
  float r = y + 1.0;
  float rx = r * cos(ang);
  float ry = r *sin (ang);

  float u = rx / (width - 1.0);
  float v = ry / (width - 1.0);

  float xOffset = cos(time + ry * 0.2) * 0.1;
  float yOffset = sin(time + rx * 0.3) * 0.1;

  float mov = (floor(vertexId /42.0));

  float ux = u * 2.0 - mov + xOffset;
  float uy = v * 2.0 - 1.0 + yOffset;

  vec2 xy = vec2 (ux, uy) * 0.2;

  gl_Position = vec4(xy, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
  gl_PointSize = 1.0;
}
