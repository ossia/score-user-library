/*{
  "DESCRIPTION": "lessons",
  "CREDIT": "mtoutside (ported from https://www.vertexshaderart.com/art/eQxQuMzXiCEc7rMYz)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 120,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.1607843137254902,
    0.1607843137254902,
    0.3254901960784314,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 7,
    "ORIGINAL_DATE": {
      "$date": 1569902901376
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 getCirclePoint(float id, float numCircleSegments) {
  float ux = floor(id / 6.) + mod(id, 2.);
  // id = 0 1 2 3

  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);

  float angle = ux / numCircleSegments * PI * 2.;
  float c = cos(angle);
  float s = sin(angle);

  float radius = vy + 1.;

    float x = c * radius;
  float y = s * radius;

  return vec2(x, y);
}

void main() {
  float numCircleSegments = 20.;
  vec2 circleXY = getCirclePoint(vertexId,
        numCircleSegments);

  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float xoff = 0.; //sin(time + y * 0.2) * .1;
  float yoff = 0.; //sin(time + x * 0.2) * .2;

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  float su = abs(u - .5) * 2.;
  float sv = abs(v - .5) * 2.;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2(au * .05, av * .25)).r;

  gl_Position = vec4(xy, 0., 1.);

  float soff = 0.; // sin(time + x * y * .002) * 5.;

  gl_PointSize = snd * 30.0 + soff;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  float pump = step(.8, snd);
  float hue = u * .1 + snd * .2 + time + .1;
  float sat = mix(0., 1., pump);
  float val = 1.; //mix(1., pow(snd + .2, 5.), pump); //sin(time + v * u * 20.) * .5 + .5;

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1.0);
}
