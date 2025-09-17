/*{
  "DESCRIPTION": "Making A Grid_hyojoonkim",
  "CREDIT": "hyojoonkim0020 (ported from https://www.vertexshaderart.com/art/3PKtnXSrJ72kySj5P)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 584,
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
    "ORIGINAL_VIEWS": 46,
    "ORIGINAL_DATE": {
      "$date": 1684265300850
    }
  }
}*/

//hyojoon kim
//Making A Grid
//cs250
//spring2023

void main(){
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount /down);
  float x = mod(vertexId ,across);
  float y = floor(vertexId/across);

  float u= x /(across-1.);
  float v= y/(across-1.);

  float ux = u* 2. -1.;
  float vy = v* 2.-1.;

  gl_Position = vec4(ux+(sin(time)/50.),vy + cos(time)/12.,0,1);
  gl_PointSize = 10.0;

  gl_PointSize *= 20. /across;
  gl_PointSize *= resolution.x /600.;

  v_color = vec4(1,0,0,1);

}