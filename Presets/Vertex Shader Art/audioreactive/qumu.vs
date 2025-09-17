/*{
  "DESCRIPTION": "qumu",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/AJ3iLGfbPGRTnZZn6)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 99647,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 73,
    "ORIGINAL_DATE": {
      "$date": 1635426883603
    }
  }
}*/

#define PI radians(180.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 rotate(vec2 point, float degree, vec2 pivot)
{
    float radAngle = -radians(degree);// "-" - clockwise
    float x = point.x;
    float y = point.y;

    float rX = pivot.x + (x - pivot.x) * cos(radAngle) - (y - pivot.y) * sin(radAngle);
    float rY = pivot.y + (x - pivot.x) * sin(radAngle) + (y - pivot.y) * cos(radAngle);

    return vec2(rX, rY);
}

void pond() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float su = abs(u - 0.5) * 2.; // center u and create symmetry;
  float sv = v;//abs(v - 0.5) * 2.;

  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2(au * .250, av * .25)).r; // Only using parts of the spectrum and 1 second of data.

  float x_offset = 0.; // sin(time + y * 0.01) * .4;
  float y_offset = 0.; // sin(time + x * 0.01) * .1;

  float ux = u * 2. - 1. + x_offset;
  float vy = v * 2. - 1. + y_offset;

  vec2 xy = rotate(vec2(ux, vy) * 0.6, time * snd, vec2(0, 0));

  gl_Position = vec4(xy, 0, 1);

  float s_offset = 0.; // sin(time + x * y * 0.03) * 2.;

  gl_PointSize = snd * 10.0 + s_offset;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  float hue = abs(sin(snd)*1.);
  float sat = 1.;
  float val = pow(snd + 0.3, 5.0);

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}

void main() {
  pond();
}