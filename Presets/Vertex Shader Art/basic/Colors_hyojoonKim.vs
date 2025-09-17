/*{
  "DESCRIPTION": "Colors_ hyojoonKim",
  "CREDIT": "hyojoonkim0020 (ported from https://www.vertexshaderart.com/art/tZ878XpvmzGfjF3hG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 16988,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1684508108904
    }
  }
}*/

//hyojoon kim
//Colors
//cs250
//spring2023

vec3 hsv2rgb(vec3 c)
{
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 P = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(P - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = abs(cos(time + y * 0.2)) * 0.1;
  float yoff = sin(time * 1.1 + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff*2.0;
  float vy = v * 2. - 1.;

  vec2 xy = vec2(ux, vy) * 1.3;

  gl_Position = vec4(xy, 0, 1);

  float soff = sin(time + 1.2 + x * y * 0.02) * 5.;

  gl_PointSize = 15.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  float hue = u ;
  float sat = v;
  float val = sin(time * 1.4 + v * u * 20.0) * .5 + .5;

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}
