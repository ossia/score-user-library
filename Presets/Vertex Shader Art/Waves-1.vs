/*{
  "DESCRIPTION": "Waves",
  "CREDIT": "chriscamplin (ported from https://www.vertexshaderart.com/art/xJtSaCNJTKWjZF5jp)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 3182,
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
    "ORIGINAL_VIEWS": 104,
    "ORIGINAL_DATE": {
      "$date": 1619726484824
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 4.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

void main() {
   float rows = floor(sqrt(vertexCount));
   float cols = floor(vertexCount / rows);
   // vertex ID is number of the vertex
   float x = mod(vertexId, rows); // divide by 10 keep the remainder,
   float y = floor(vertexId / rows); //. floor throws away the remainder 0000 1111 2222
   float s = sin(PI * time + y * 0.25);
   float xOff = sin(time + y * 0.025) * 0.1;
   float yOff = sin(time - x * 0.25) + s * 0.1;

   float u = x /(rows - 1.);
   float v = y / (rows - 1.);
   float ux = u * 2. - 1. + xOff;
   float vy = v * 2. - 1. + yOff;
   float soff = sin(time + x * y * 0.05) * mouse.x;
 gl_Position = vec4(ux, vy, 0, 1);
   gl_PointSize = 4.0 - soff;
   gl_PointSize *= 20.0 / cols;
   gl_PointSize *= resolution.x / 600.;
   v_color = vec4(yOff-s, 0.0666, s+xOff, 1);
}