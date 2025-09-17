/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/xX4FaCRBAKRKxwQ5k)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 8,
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
    "ORIGINAL_VIEWS": 100,
    "ORIGINAL_DATE": {
      "$date": 1586780569442
    }
  }
}*/

void main() {

   gl_PointSize = 20.0;

//divide vertex id number by a number
  vec2 xy = vec2(vertexId / 8.0, vertexId /8.0);

//alpha changed distance between vertices
  //xy is a variable dividing each vertex by a number
  gl_Position = vec4(xy, 0.0, 2.5);

//add vertexcolor to the shader
  v_color = vec4 (0.5, 0.0, 1.0, 1.0);

 // vec2 xy = vec2(-0.5, 0.0);

  if (vertexId == 1.0)
  {
  xy = vec2(0, 0.5);

  }
  else if (vertexId == 2.0)
  {
    xy + vec2(0.5, 0);
  }

  //xy += vec2(0, sin(time));

  gl_Position =vec4(xy, 0.0, 1.0);
  gl_PointSize = 10.0;

  v_color = vec4(1.0, 0.0, 0.0, 1.0);
}