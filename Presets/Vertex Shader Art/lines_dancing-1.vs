/*{
  "DESCRIPTION": "lines_dancing?",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/gxQFmkRMFP6oHs6Qb)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 41002,
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
    "ORIGINAL_VIEWS": 86,
    "ORIGINAL_DATE": {
      "$date": 1572858129900
    }
  }
}*/

mat2 rotate2D(float x)
{
  float a = sin(x), b = cos(x);
  return mat2(b, -a, a, b);
}

void main()
{
  float tmp = 2.0 * abs(sin(time * 0.02)) * 10.0;
  if(1==1){
   tmp = 4.0 * abs(sin(time * 0.02)) * 10.0;
  }

  float posx = (vertexId / vertexCount - 0.5) * 3.0;
  float posy = fract(posx * tmp);

  vec2 pos = vec2(posx, posy * sin(posx + time));

  gl_PointSize = 2.0;
  gl_Position = vec4(pos, 0.0, 1.0);
  v_color = vec4(1.0);
}