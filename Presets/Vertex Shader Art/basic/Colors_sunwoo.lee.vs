/*{
  "DESCRIPTION": "Colors_sunwoo.lee",
  "CREDIT": "sunwoo.lee (ported from https://www.vertexshaderart.com/art/7e3M2Sgrztb9vDD7v)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 150,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.26666666666666666,
    0.3176470588235294,
    0.16470588235294117,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_DATE": {
      "$date": 1652934711843
    }
  }
}*/

// // Name: sunwoo.lee
// // Assignment name: Colors
// // Course name: CS250
// // Term: 2022 Spring

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = 0.0;//sin(time + y * 0.2) * 0.1;
  float yoff = sin(time + x)*0.005;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux,vy) * 1.3;

  gl_Position = vec4(xy,0,1);

  float soff = 0.0; //sin(time * 1.2 + x * y * 0.02) * 5.0;

  gl_PointSize = 15.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.0;

  float hue = sin(time*0.5+x*y)*0.5+0.5; // Hue(Color difference)
  float sat = 0.7; // Saturation(Colorfulness)
  float val = 1.0; // Lightness(Brightness)

  v_color = vec4(hsv2rgb(vec3(hue,sat,val)),1);

}