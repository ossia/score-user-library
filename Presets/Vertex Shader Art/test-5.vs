/*{
  "DESCRIPTION": "test",
  "CREDIT": "lambmeow (ported from https://www.vertexshaderart.com/art/LorQPsDrEHNowrcw5)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 466,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.2784313725490196,
    0.00784313725490196,
    0.9176470588235294,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 84,
    "ORIGINAL_DATE": {
      "$date": 1494693101012
    }
  }
}*/

void main(){
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount/down);
  float x = mod(vertexId,across);
  float y = floor(vertexId/across);
  float u = x/(across-1.);
  float v = y/(across- 1.);
  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;
  gl_Position = vec4(ux,vy,0,1);
  gl_PointSize = 10.;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x/ 600.;
  v_color = vec4(u,v,0,1);
}