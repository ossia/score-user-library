/*{
  "DESCRIPTION": "Audio Reactive Art - Tweak",
  "CREDIT": "joonho.hwang (ported from https://www.vertexshaderart.com/art/iCRwaQsZvFQ2eLheK)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Particles",
    "Abstract"
  ],
  "POINT_COUNT": 12649,
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
    "ORIGINAL_VIEWS": 8,
    "ORIGINAL_DATE": {
      "$date": 1684750815626
    }
  }
}*/

// Joonho Hwang
// Exercise Audio Reactive
// CS250 Spring 2022

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

const float PI = 3.14159265358979;

void main()
{
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float xOffset = 0.0;
  float yOffset = 0.0;

  float ux = u * 2.0 - 1.0 + xOffset;
  float vy = v * 2.0 - 1.0 + yOffset;

  vec2 xy = vec2(ux, vy) * 1.3;

  float su = abs(u - 0.5) * 2.0;
  float sv = abs(v - 0.5) * 2.0;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2(au * 0.1, av * 0.25)).r;

  gl_Position = vec4(xy + vec2(texture(sound, vec2(au * 0.0001, av * 0.1)).r) - vec2(0.8), 0.0, 1.0);

  float sizeOffset = 0.0;

  gl_PointSize = pow(snd + 0.1, 7.0) * 30.0 + sizeOffset;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;

  float pump = step(0.8, snd);

  const float range = 120.0;
  const float block = 120.0 / 240.0;
  float sum = 0.0;
  for (float b = 0.0; b < range / 240.0; b += block)
  {
    sum += texture(sound, vec2(b, av * 0.25)).r;
  }

  float hue = sum / block;
  float saturation = mix(0.0, 1.5, snd);
  float value = mix(0.1, pow(snd + 0.15, 5.0), snd);

  v_color = vec4(hsv2rgb(vec3(hue, saturation, value)), 1);
}