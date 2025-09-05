/*{
  "DESCRIPTION": "whirl",
  "CREDIT": "kcha (ported from https://www.vertexshaderart.com/art/cMqY3Hixco2WwFZo6)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 150,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 111,
    "ORIGINAL_DATE": {
      "$date": 1551283204610
    }
  }
}*/

#define PI 3.14159265

void main() {
  float r_speed = 0.75;

  // 0-100 => 0.0-1.0
  float f_vertexId = vertexId / (vertexCount - 1.);
  // 0.0-1.0 => 0.0-0.8
  float radius = f_vertexId * 0.8;

  // 0-99 => 0.0-1.0 => 0.0-2PI
  float radian = vertexId / (vertexCount - 1.) * 2. * PI;
  radian *= 3.0;

  float x = cos(-radian + time * r_speed) * radius;
  float y = sin(-radian + time * r_speed) * radius;
  vec2 xy = vec2(x, y);
  gl_PointSize = 10.;
  gl_Position = vec4(xy, 0., 1.);
  v_color = vec4(1., x / 0.8, y / 0.8, 1.);

}