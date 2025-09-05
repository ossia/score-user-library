/*{
  "DESCRIPTION": "grid",
  "CREDIT": "\ubc15\uc0c1\uc900(\ud559\ubd80\ud559\uc0dd/\uc0dd\uba85\uc2dc\uc2a4\ud15c\ub300\ud559\uc0dd\uba85\uacf5\ud559) (ported from https://www.vertexshaderart.com/art/n7ipvkgkeT93uBRGq)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.03529411764705882,
    0,
    0.2196078431372549,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 9,
    "ORIGINAL_DATE": {
      "$date": 1631522323972
    }
  }
}*/

void main() {
 float down = floor(sqrt(vertexCount));
 float across = floor(vertexCount / down);

 float x = mod(vertexId, across);
 float y = floor(vertexId / across);

 float u = x / (across - 1.);
 float v = y /(across - 1.);

 float xoff = sin(time + y * 0.1);
 float yoff = sin(time + x * 0.2);

 float ux = u * 2. - 1. + xoff;
 float vy = v * 2. - 1. + yoff;

 vec2 xy = vec2(ux, vy)*0.5;

 gl_Position = vec4(xy,0,1);

 float soff = sin(time) * 5.;

 gl_PointSize = 10.0 + soff;
 gl_PointSize *= 20. / across;
 gl_PointSize *= resolution.x / 600.;
 v_color = vec4(1, 0, 0, 1);

}
