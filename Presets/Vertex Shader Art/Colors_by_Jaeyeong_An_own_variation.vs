/*{
  "DESCRIPTION": "Colors by Jaeyeong An(own variation) - Duplicate the shader and tweak it to make my own variation",
  "CREDIT": "jaeyeong-an (ported from https://www.vertexshaderart.com/art/EFczFa8BRmNtBibqB)",
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
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_DATE": {
      "$date": 1684479508492
    }
  }
}*/

//Name : Jaeyeong An
//Assignment : Exercise - Vertexshaderart : Colors
//Course : CS250
//Term : 2023 Fall

vec3 hsv2rgb(vec3 c)
{
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float down = sqrt(vertexCount);
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = tan(time + y * 0.2) * 0.1;
  float yoff = tan(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  gl_Position = vec4(xy, 0, 1);

  float soff = sin(time + x * y * .02) * 5.;

  gl_PointSize = 15.0 + soff;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;

  float hue = u * .1 + sin(time * 1.3 + v * 20.) * 0.5;
  float sat = 1.;
  float val = sin(time * 1.4 + v * u * 20.0) * .5 + .5;

  v_color = vec4( hsv2rgb( vec3(hue, sat, val) ), 1 );
}