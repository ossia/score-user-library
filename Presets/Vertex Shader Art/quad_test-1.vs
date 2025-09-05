/*{
  "DESCRIPTION": "quad test",
  "CREDIT": "monguri (ported from https://www.vertexshaderart.com/art/M3TQnRJ4QA4c5vpBc)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 4,
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
    "ORIGINAL_VIEWS": 166,
    "ORIGINAL_DATE": {
      "$date": 1520747519603
    }
  }
}*/

vec2 getPosition(vec2 resolution, float index)
{
 float signX = ((index < 2.0) ? -1.0 : 1.0);
 float signY = ((index == 0.0 || index == 3.0) ? -1.0 : 1.0);
 return vec2(
  resolution.x * 0.25 * signX * 0.001,
  resolution.x * 0.25 * signY * 0.001
 );
}

void main() {
 gl_Position = vec4(getPosition(resolution, vertexId).xy, 0, 1);
 v_color = vec4(1, 1, 1, 1);
}
