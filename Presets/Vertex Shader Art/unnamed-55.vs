/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "valentin (ported from https://www.vertexshaderart.com/art/Emf9HTtBkjpcSmC3a)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 10,
    "ORIGINAL_DATE": {
      "$date": 1507997065502
    }
  }
}*/



void main() {

  float n = vertexId/1.0;

  float angle = 1.45*sin(n*0.23);
  float radius = cos(n*0.1) * tan(angle*0.9);

  float scale = 0.2;

  float x = radius*sin(angle) * cos(2.0*time) * cos(2.0*time) * scale * 0.12;
  float y = radius*cos(angle) * scale;

  float red = abs(x*9.0);
  float green = abs(y*9.0);
  float blue = 1.0;

  x += 0.6*sin(time*0.5);
  y += 0.25*cos(time*1.8);

  //bool beg = mod(vertexId, 2) ? true : false;

  //float x = 0.05*n;
  //float y = 0.05*n;

  gl_Position = vec4(x, y, 0, 1);

  gl_PointSize = 10.0;

  v_color = vec4(red, green, blue, 1);
}