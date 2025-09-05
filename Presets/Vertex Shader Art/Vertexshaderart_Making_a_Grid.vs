/*{
  "DESCRIPTION": "Vertexshaderart : Making a Grid - Vertexshaderart : Making a Grid\nHyosang Jung",
  "CREDIT": "hyosang_jung (ported from https://www.vertexshaderart.com/art/BSig2nJzr4kavRSF2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles",
    "Abstract"
  ],
  "POINT_COUNT": 1000,
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
    "ORIGINAL_VIEWS": 117,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1652801184186
    }
  }
}*/

//Name: Hyosang Jung
//Assignment Name: Vertexshaderart : Making a Grid
//Course Name: CS250
//Term&Year: 2022&Spring
void main(){
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId/across);
  float u = x/(across-1.);
  float v = y/(across -1.);
  float ux =u*2.-1.;
  float vy = v*2.-1.;

  gl_Position = vec4(ux,vy,0,1);
  gl_PointSize = 10.0;
  gl_PointSize +=20./across;
  gl_PointSize += resolution.x / 600.;

  v_color = vec4(1,0,0,1);

}