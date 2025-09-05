/*{
  "DESCRIPTION": "grid",
  "CREDIT": "rlmp (ported from https://www.vertexshaderart.com/art/AZ2KyvbW28MmPCFKA)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 13087,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.15294117647058825,
    0.12941176470588237,
    0.43529411764705883,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1585500385787
    }
  }
}*/

void main() {
  float down= floor(sqrt(vertexCount));
  float across = floor(vertexCount/down);

  float x = mod(vertexId, across);
  float y = floor(vertexId /across);
  float u = x/(across-1.);
  float v = y/(across-1.);

  float xoff = sin(time+y*0.1) * 0.5 ;
  float yoff = cos(time+x*0.2)*0.05;

  float ux = 2.*u-1.+xoff;
  float vy = 2.*v-1.+yoff;

  vec2 xy = vec2(ux,vy)*0.8;

  gl_Position = vec4(xy,0,1);

  gl_PointSize = 10.0 +sin(time)+cos(y*x*0.5)*5.;
  gl_PointSize*=20./across;
  gl_PointSize*=resolution.x/600.;

  v_color = vec4(1,0,0,1)

}