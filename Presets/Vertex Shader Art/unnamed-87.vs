/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/PG4Ca7xxyoYxNdTGe)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.30196078431372547,
    0.30196078431372547,
    0.30196078431372547,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 21,
    "ORIGINAL_DATE": {
      "$date": 1691504160344
    }
  }
}*/

void main() {

  float accross = 30.;

  float x = mod(vertexId,accross);

  float y = floor(vertexId/accross);

  float u = x/(accross-1.0);
  float v = y/(accross-1.0);

  float ux = u *2.0 -1.0;
  float vy = v *2.0 -1.0;

  gl_Position = vec4(ux,vy,0,1);
  gl_PointSize = 10.0;
  v_color = vec4(1,0,0,1)

}