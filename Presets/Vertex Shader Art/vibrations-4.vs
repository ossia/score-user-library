/*{
  "DESCRIPTION": "vibrations",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/wFdw32QXQhDAXDLmi)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 25957,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.058823529411764705,
    0.058823529411764705,
    0.058823529411764705,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 102,
    "ORIGINAL_DATE": {
      "$date": 1536319148480
    }
  }
}*/

// chrillo

#define PI 3.14159

float hash( float n ) { return fract(sin(n)*753.5453123); }

void main () {
  float i = hash(vertexId);
  float f = hash(i);
  float snd = texture(sound, vec2(f, i)).r * cos(i);
  snd = pow(snd, 2.);

  float ang = vertexId / 1000.;
  float perspective = .5 * (1. - mouse.y);
  float t = time * (f + .5) - mouse.x;
  float x = i * sin(ang + t) * .8;
  float y = i * cos(ang + t);
  y += .1 * snd * (1. - y);
  y *= perspective;

  float vis = snd / (y + 1.);

  gl_Position = vec4(x, y, 0., 1.);
  gl_PointSize = 5. * vis;

  v_color = vec4(
    snd * .7 * (2. - f),
    snd * .8 * cos(f * PI),
    snd * 2.,
    vis);
}