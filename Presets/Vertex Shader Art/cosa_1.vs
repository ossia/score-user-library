/*{
  "DESCRIPTION": "cosa 1",
  "CREDIT": "anuar (ported from https://www.vertexshaderart.com/art/cprWonx4tN8nMgQHt)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 175,
    "ORIGINAL_DATE": {
      "$date": 1517960564826
    }
  }
}*/

void main(){
float width = floor(sqrt(vertexCount));
float x = mod(vertexId,width);
float y = floor(vertexId/width);

float u = x/(width - 1.0);
float v = y/(width - 1.0);

float xOffset = cos(time + y * .2) *.1;
float yOffset = cos(time + x * .2) *.1;

float ux = u*2.0 - 1.0 + xOffset;
float vy = v*2.0 - 1.0 + yOffset;

//vertex id 0 1 2 3 4 ... 10 11 12 ... 20 21 22
//mod X 0 1 2 3 4 ... 0 1 2 ... 0 1 2
//floor Y 0 0 0 0 0 ... 1 1 1 ... 2 2 2

vec2 xy = vec2(ux,vy)*1.2;

float sizeOffSet = sin(time + x * y * .2)*5.;

gl_Position = vec4(xy, 0.0, 1.0);
gl_PointSize = 15.0 + sizeOffSet;
gl_PointSize*= 32.0 / width;
v_color = vec4(47.0, 211.0, 0.0, 1.0);

}