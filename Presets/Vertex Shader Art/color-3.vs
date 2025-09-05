/*{
  "DESCRIPTION": " color",
  "CREDIT": "nathan (ported from https://www.vertexshaderart.com/art/umxyfipbWA28PZZu5)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1533,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0.12549019607843137,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1496860212366
    }
  }
}*/

vec3 hsv2rgb(vec3 c){
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
    }

void main(){
  float down = floor(sqrt(vertexCount));

 float across = floor(vertexCount / down);

//START
  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across -1.);

  float xoff = 0. ;//sin(time + y * 0.2) * 0.1;
  float yoff = 0. ;//sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  gl_Position = vec4(xy, 0, 1);

  float soff = 0.;//sin(time * y * 0.02) * 5.;

  gl_PointSize = 10.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;
  //float hue = u * .1 + sin(time + v * 20.);
  float hue = u * 0.9; // hue = 0-1 (0.1, 0.2 etc. 0 and 1 are red, the others are colours)
  float sat = 1.; // color to grey
  float val = 1.;
  //float val = sin(time + v * u * 20.0);
  v_color = vec4(hsv2rgb(vec3(hue,sat,val)),1);

}