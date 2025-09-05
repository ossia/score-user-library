/*{
  "DESCRIPTION": "template",
  "CREDIT": "rus-abd (ported from https://www.vertexshaderart.com/art/nQhGyYPDnC9Sj6iak)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 226,
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1705873210231
    }
  }
}*/



vec2 getPosition(){
   float down = floor(sqrt(vertexCount));
   float across = floor(vertexCount/down);

   float x = mod(vertexId,across);
   float y = floor(vertexId/across);

    float u = x / (across-1.);
    float v = y / (across-1.);

   vec2 res = (vec2(u,v) - .5) *2.;
 return vec2(res);
}

void main() {

  vec3 position = vec3(getPosition(),.1);

  gl_PointSize = 2. * (1./position.z);

   gl_Position = vec4(position,1.);
   v_color = vec4(1.,1.,1.,1.);
}