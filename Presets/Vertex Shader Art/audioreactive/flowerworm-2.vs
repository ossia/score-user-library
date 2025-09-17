/*{
  "DESCRIPTION": "flowerworm - by johan",
  "CREDIT": "athega (ported from https://www.vertexshaderart.com/art/xgrH8Ga7yhuDYom6t)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 54268,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 157,
    "ORIGINAL_DATE": {
      "$date": 1486746288617
    }
  }
}*/

// johan

#define PI radians(180.)

void main() {

  float aspect = resolution.x / resolution.y;

  float cPoints = 64.;
  float circles = ceil(vertexCount / cPoints);
  float cId = floor(vertexId / cPoints);
  float cNorm = cId / circles;
  float vId = mod(vertexId, cPoints);

  float a = 2. * PI * vId / (cPoints - 1.);

  float snd = pow(texture(sound, vec2(0.05, cNorm * .125)).r, 4.);

  float rad = 0.05 + 0.1 * (1. - cNorm) + sin(a * 10.) * (0.05 + 0.3 * snd);
  float x = sin(a) * rad;
  float y = cos(a) * rad;

  x += sin(time * 1.23 + cId / 133.3) * .3;
  y += cos(time * 1.09 - cId / 159.2) * .3 / aspect;

  x += sin(time * 1.31 + cId / 171.3) * .4;
  y += cos(time * 1.49 - cId / 147.2) * .4 / aspect;

  gl_Position = vec4(x, y * aspect, 0, 1);

  float r = sin(time * 1.42 - cNorm * 8.) * .5 + .5;
  float g = sin(time * 1.27 + a) * .5 + .5;
  float b = sin(time * 1.12 + cNorm * 6.) * .5 + .5;

  v_color = vec4(r, g, b, 1);
}