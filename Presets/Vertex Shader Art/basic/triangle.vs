/*{
  "DESCRIPTION": "triangle",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/aW7ux7BBYH5aNYM6h)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 20000,
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
    "ORIGINAL_VIEWS": 75,
    "ORIGINAL_DATE": {
      "$date": 1536052518135
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

void main() {

  vec2 p = vec2(0,0);

  if(vertexId < 0.5){
    p = vec2 (0., 0.5);
  }else if (vertexId < 1.5)
  {
     p = vec2 (0.5, -0.5);
  }else if (vertexId < 2.5)
  {
     p = vec2 (-0.5, -0.5);
  }

  gl_Position = vec4(p, 0., 1.);

  v_color = vec4(1,1,1, 1);
}

