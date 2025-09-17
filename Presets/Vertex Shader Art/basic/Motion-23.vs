/*{
  "DESCRIPTION": "Motion - Animation Test",
  "CREDIT": "cjensen93 (ported from https://www.vertexshaderart.com/art/epH8co5uSwMkCYZGo)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.06666666666666667,
    0.058823529411764705,
    0.4117647058823529,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1590717563542
    }
  }
}*/

void main(){

  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float xOff = sin(time + y * 0.2) * 0.1;
  float yOff = sin(time + x * 0.3) * 0.2;

  float ux = u * 2.0 - 1.0 + xOff;
  float uy = v * 2.0 - 1.0 + yOff;

  vec2 xy = vec2(ux, uy) * 1.3;

  gl_Position = vec4(xy,0.0,1.0);

  float sOff = sin(time + x * y * 0.02) * 5.0;

  gl_PointSize = 10.0 + sOff;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;

  v_color = vec4(1.0,0.0,0.0,1.0);
}