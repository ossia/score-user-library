/*{
  "DESCRIPTION": "asdf",
  "CREDIT": "lambmeow (ported from https://www.vertexshaderart.com/art/FqNcEyWQSSAnHAtMY)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 20000,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1494695602138
    }
  }
}*/

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
void main(){
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount/down);
  float x = mod(vertexId,across);
  float y = floor(vertexId/across);
  float u = x/(across-1.);
  float v = y/(across- 1.);
  float xoff = sin(time + x * .2) *.1;
  float yoff = sin(time + y * .3) *.2;
  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 posoff = vec2(ux,vy) ;

  gl_Position = vec4(posoff,0,1);

  float soff = sin(time + 20. * ux * vy);
  gl_PointSize = 10. + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x/ 600.;

  float hue = u * .1 + sin(time + v * 20.) * .05;
  float sat = 1.;
  float val = sin(time + v* u* 20.);
  v_color = vec4(hsv2rgb(vec3(hue,sat,val)),1);
}