/*{
  "DESCRIPTION": "Triangles",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/748RN8qRjrDrtSGy2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 19,
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
    "ORIGINAL_VIEWS": 49,
    "ORIGINAL_DATE": {
      "$date": 1536517222523
    }
  }
}*/

void main(){
  float width = 10.0;

  float y = -floor(vertexId/ 2.0);
  float x = mod(vertexId, 2.0);

  vec2 xy = vec2(x,y)*0.1;

  //float xOffset = cos(time + y * 0.05);
  //float yOffset = sin(time + x * 0.05);

  //float ux = u * 2.0 -1.0;
  //float vy = v * 2.0 -1.0;

  gl_Position = vec4(xy,0.0,1.0);
  gl_PointSize = 20.0;
  v_color = vec4(1.0,0.4,0.1,1.0);

}