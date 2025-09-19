/*{
  "DESCRIPTION": "circle",
  "CREDIT": "gerrygoo (ported from https://www.vertexshaderart.com/art/Br7jzCr5r8jf4kHyx)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1551483966237
    }
  }
}*/

void main()
{
  float width = 10.0;

  float tot = 30.0;

  float pi = 3.141592654;
  float ang = tot/pi;

  float w = 0.1;
  float h = 0.1;

  float vid = vertexId;

  float x = w * floor(vid / 2.0) + cos(ang * vid);
  float y = h * mod(vid, 2.0) - sin(ang * vid);

  gl_Position = vec4(x, y, 0.0, 1.0);

  v_color = vec4(sin(time * vid), 1.0, cos(time * vid), 1.0);
  gl_PointSize = 10.0;
}

