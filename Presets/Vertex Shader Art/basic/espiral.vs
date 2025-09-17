/*{
  "DESCRIPTION": "espiral",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/DjWJQf8DFiu4EnvvZ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 64,
    "ORIGINAL_DATE": {
      "$date": 1518201313084
    }
  }
}*/


vec2 createCircle(float id){
  float ux = floor(id / 6.0) + mod(id, 2.0);
  //float vy = mod(floor(id / 2.0) + floor (id /3.0), 2.0);
  float vy = floor(id) + mod(id, 3.0);

  float angle = ux /2.0;
  float radius = vy;

  float x = radius * cos(angle);
  float y = radius * sin(angle);

  return vec2(x,y);
}

void main()
{

  vec2 xy = createCircle(vertexId)*0.01;

  gl_Position= vec4(xy , 0.0, 1.0);
  v_color = vec4(1.0, 0.0, 0.0, 1.0);
}
