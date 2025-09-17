/*{
  "DESCRIPTION": "Making A Grid with Changes",
  "CREDIT": "junsujang-digipen (ported from https://www.vertexshaderart.com/art/p2aq6zzbjEuF3wArG)",
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
    0.18823529411764706,
    0.18823529411764706,
    0.18823529411764706,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 11,
    "ORIGINAL_DATE": {
      "$date": 1652625915192
    }
  }
}*/

// Junsu Jang
// Exercise Making A Grid
// CS250
// Spring/2022

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount/down);

  float x = mod(vertexId, across);
  float y = floor(vertexId/across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  gl_Position = vec4(ux, vy , 0., 1.);

  gl_PointSize = 10.0 * (sin(time)+1.1);
  gl_PointSize *= 20./across;
  gl_PointSize *= resolution.x / 1200.;

  float distNum = 20.;
  vec2 pos = gl_Position.xy/resolution;
  pos += vec2(sin(time*0.1),cos(time*0.1));
  pos *= distNum;
  vec2 intPos = floor(pos)*resolution ;

  v_color = vec4(sin(intPos.x),sin(intPos.y),cos(intPos.x),1);
  //background = vec4(sin(intPos.y),sin(intPos.x),cos(intPos.y));

}