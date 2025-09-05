/*{
  "DESCRIPTION": "Velocity modeling - Slowly starting to understand, coordinate system is a bit strange compared to normal canvas, got to get used to that",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/bmeg6H2QQu9rgbn4o)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Animated"
  ],
  "POINT_COUNT": 1,
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1524509172054
    }
  }
}*/

void main() {
  float vy = mod(time, 2.); // the distance to travel is 2 units, let time increment the velocity and reset when the unit traveled is 2

  gl_Position = vec4(0.0, 1.0 - vy, 0.0, 1.0); // minus velocity because coords inverted
  gl_PointSize = 10.0;
  v_color = vec4(1., 1., 1., 1.);
}