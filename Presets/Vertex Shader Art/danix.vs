/*{
  "DESCRIPTION": "danix",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/MA9L7t9wKoSZh4sHG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 30452,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.5019607843137255,
    0,
    0.25098039215686274,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 66,
    "ORIGINAL_DATE": {
      "$date": 1536370561092
    }
  }
}*/

void main() {
  float width = 10.0;

  float x =mod( vertexId,width);
  float y = floor (vertexId / width);

  float u= x / (width - 1.0);
  float v = y / (width - 1.0);

  float xOffset = cos(time + y *0.2)*0.1;
  float yOffset = sin(time + x * 0.3) * 0.2;

  float ux = u * 2.0 - 1.0 * xOffset;
  float vy = v * 2.0 - 1.0;

  gl_Position = vec4(0,0,0,1.0);
  gl_PointSize = 40.0;
  v_color = vec4(1.0,0.0,0.0,2.0);

}