/*{
  "DESCRIPTION": "ejercicio2",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/vqWQHJrgtfjyuWZXw)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1,
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
    "ORIGINAL_VIEWS": 82,
    "ORIGINAL_DATE": {
      "$date": 1553214184318
    }
  }
}*/

/*void main(){
//Vector 4
  float width = 20.0;
  float row = 42.0 * 15.0;
  float circleID = mod(vertexId, row);

  float y = mod(vertexId + 1.0, 2.0);
  float x = floor(vertexId / 2.0);
  float movx = floor(circleID/42.0) * 1.1;
  float movy = floor(vertexId/ row) * 1.1;
  float ang = (x/20.0)*radians(360.0);
  float r = 2.0 - y;
  float rx = r * cos(ang);
  float ry = r *sin (ang);

  float u = rx / (width - 1.0);
  float v = ry / (width - 1.0);

  float xOffset = cos(time + movy * 0.2) * 0.1;
  float yOffset = sin(time + movx * 0.2) * 0.1;

  float ux = u * 2.0 - 1.0 + xOffset;
  float uy = v * 2.0 - 1.0 + yOffset;

  vec2 xy = vec2 (ux + movx, uy + movy) * 0.1;

  gl_Position = vec4(xy, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
  gl_PointSize = 1.0;
}*/

void main() {
  float y = mod(vertexId + 1.0, 2.0);
  float x = floor(vertexId / 2.0);
  float ang = (x/20.0)*radians(360.0);
  float phi = 1.5;
  float p = 0.1;
  float rx = p * sin(phi) * cos(ang);
  float ry = p * cos(phi) * sin (ang);
  float rz = p * cos(phi);

  gl_Position = vec4(rx, ry, rz, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
  gl_PointSize = 5.0;

}
