/*{
  "DESCRIPTION": "lesson01",
  "CREDIT": "xi (ported from https://www.vertexshaderart.com/art/hx3wegzB6mT7kmxAg)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0.0196078431372549,
    0.2784313725490196,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1590975327395
    }
  }
}*/

void main(){
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x/(across-1.);
  float v = y/(across-1.);

  float ux = u * 2. -1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux,vy,0,1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20./across;
  gl_PointSize *= resolution.x/600.;

  v_color = vec4(1,0,0,1);
}