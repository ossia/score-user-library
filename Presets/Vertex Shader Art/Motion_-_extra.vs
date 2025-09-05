/*{
  "DESCRIPTION": "Motion - extra",
  "CREDIT": "junsujang-digipen (ported from https://www.vertexshaderart.com/art/uXzMte5jWZa5aMKgf)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 7407,
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
    "ORIGINAL_VIEWS": 9,
    "ORIGINAL_DATE": {
      "$date": 1652627643925
    }
  }
}*/

// Junsu Jang
// Exercise - Vertexshaderart : Motion
// CS250
// Spring/2022

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount/down);

  float x = mod(vertexId, across);
  float y = floor(vertexId/across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = sin(time+y*0.2)*0.1;
  float yoff = sin(time+x*0.3)*0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux,vy)*1.3;

  gl_Position = vec4(xy, 0., 1.);

  float soff = sin(time+x*y*0.02)*5.;

  gl_PointSize = 15.0 + soff;
  gl_PointSize *= 20./across;
  gl_PointSize *= resolution.x / 600.;

  //gl_PointSize = 10.;
  vec2 pos = gl_Position.xy * resolution;
  v_color = vec4(pos.x,pos.y,cos(pos.x),1.);

}