/*{
  "DESCRIPTION": "Vertexshaderart : Making a Grid NEW - Vertexshaderart : Making a Grid\n",
  "CREDIT": "hyosang_jung (ported from https://www.vertexshaderart.com/art/3cvdmf4HtiuwSqeR8)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Abstract"
  ],
  "POINT_COUNT": 100,
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
    "ORIGINAL_VIEWS": 85,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1652801874419
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
  ux = sin(ux+time);
  vy = cos(vy+time);

  gl_Position = vec4(ux,vy,0,1);
  gl_PointSize = 10.0;
  gl_PointSize +=20./across;
  gl_PointSize += resolution.x / 600.;

  v_color = vec4(abs(ux),abs(vy),0,1);

}