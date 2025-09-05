/*{
  "DESCRIPTION": "Init V",
  "CREDIT": "richtowns (ported from https://www.vertexshaderart.com/art/c9GGGN9nw3aPqNYBW)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0.25098039215686274,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1495058960097
    }
  }
}*/

// I HAD TO STEAL THIS !!!!!

void main(){
  float grid = 20.;
  float scale = 20.;

  float x = mod(vertexId, grid );
  float y = mod(floor(vertexId / grid), grid);

  float xmod = 1. / scale;
  float ymod = 1. / scale;

  float xoff = 0. - (10. / (scale + grid));
  // float xoff = xoff + sin(time);
  float yoff = 0. - (10. / (scale + grid));

  gl_Position = vec4(x * xmod + xoff, y * ymod + yoff,0 ,1);

  gl_PointSize = 10.0;

  v_color = vec4(1,0,0,1);

}