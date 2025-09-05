/*{
  "DESCRIPTION": "yGlitchPointNumber",
  "CREDIT": "macro (ported from https://www.vertexshaderart.com/art/gBa8KAJTb6MqbNzBK)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 807,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1522431693493
    }
  }
}*/

void main(){
  float w = sqrt(vertexCount);
  float h = 10.;
  float x = mod(vertexId, w);
  float y = floor(vertexId/h);
  float u = x/(w-1.);
  float v = y/(h-1.);
  float ux = u*2.-1.;
  float vy = v*2.-1.;
  gl_Position = vec4(ux,vy,0.,1.);
  gl_PointSize = 10.;
  v_color = vec4(1.);
}

/*
void main(){
  float w = sqrt(vertexCount);
  float h = 10.;
  float x = mod(vertexId, w);
  float y = floor(vertexId/h);
  float u = x/(w-1.);
  float v = y/(h-1.);
  float ux = u*2.-1.;
  float vy = v*2.-1.;
  gl_Position = vec4(ux,vy,0.,1.);
  gl_PointSize = 10.;
  v_color = vec4(1.);
}
*/