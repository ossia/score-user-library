/*{
  "DESCRIPTION": "pointsprite plasma",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/8aEFjza4wNjuhfnvP)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 3,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 93,
    "ORIGINAL_DATE": {
      "$date": 1497092016928
    }
  }
}*/



void main()
{
  vec2 xy = vec2(0.0, 0.0);

  if(vertexId == 0.0)
  {

    xy = vec2(0.5, 0.0);

  }

  if(vertexId == 1.0)
  {

    xy = vec2(-0.5, 0.0);

  }

  if(vertexId == 2.0)
  {

    xy = vec2(0.0, 0.5);

  }
  xy += vec2(0.0,-0.2);
  xy += vec2(0.0, sin(time)/20.0*10.0);

  gl_Position = vec4(xy, 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
  gl_PointSize = 10.0;

}