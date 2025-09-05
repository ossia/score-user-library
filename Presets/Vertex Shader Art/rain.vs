/*{
  "DESCRIPTION": "rain",
  "CREDIT": "mark (ported from https://www.vertexshaderart.com/art/n52WuRHLrJFWonAPp)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 8086,
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
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1454016644920
    }
  }
}*/

#define FALLTIME 5.

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main () {
  float i = vertexId;
  float tdiff = 0.;
  if (mod(vertexId, 2.) > 0.) {
    i -= 1.;
    tdiff = -.01;
  }

  float fallTime = 1. + rand(vec2(i, 0.2423424)) * FALLTIME;

  float t = mod(time, fallTime) + tdiff;

  float y = -2. * (t / fallTime) + 1.;
  float x = -1.5 + rand(
    vec2(i, floor(time / fallTime))
  ) * 3. + .2 / fallTime * t;
  y += .1 * sin(x + t);

  float l = .7 + .3 * sin(t);
  gl_Position = vec4(x, y, 0, 1);
  v_color = vec4(l, l, l, 1);
}