/*{
  "DESCRIPTION": "Audio Reactive Art - Audio Reactive Art - CS250 \nspring  2023\n",
  "CREDIT": "seongryul.park (ported from https://www.vertexshaderart.com/art/eq35fsTk4w4ZA3LQF)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Abstract"
  ],
  "POINT_COUNT": 10000,
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
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1684959370516
    }
  }
}*/


// seongryul.park
// CS250 spring 2023
// Audio Reactive Art

vec3 hsv2rgb(vec3 c)
{
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));

  vec4 k = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + k.xyz) * 6.0 - k.www);
  return c.z * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y);
}

#define PI radians(180.0)

void main()
{
 float down = floor(sqrt(vertexCount));
   float across = floor(vertexCount / down);

   float x = mod(vertexId, across);
   float y = floor(vertexId/ across);

   float u = x / (across - 1.);
   float v = y / (across - 1.);

   float xoff = 0.;//sin(time + y * 0.2) * 0.1;
   float yoff = 0.;//sin(time + x * 0.3) * 0.2;

   float ux = u * 2. - 1. + xoff;
   float vy = v * 2. - 1. + yoff;

   vec2 xy = vec2(ux, vy) * 1.3;

   float su = abs(u - 0.5) * 2.0;
   float sv = abs(v - 0.5) * 2.0;
   float au = abs(atan(su, sv)) / PI;
   float av = length(vec2(su, sv));
   float snd = texture(sound, vec2(au * 0.05, av * 0.25)).r;

   gl_Position = vec4(xy, 0, 1);

   float soff = 0.;//sin(time * 1.2 + x * y * 0.02) * 5.;

   gl_PointSize = pow(snd + 0.2, 5.0) * 30.0 + soff;
   gl_PointSize *= 20.0 / across;
   gl_PointSize *= resolution.x / 600.;

   float pump = step(0.8, snd);
   float hue = u * .1 + snd * 0.2 + time * 0.1;
   float sat = mix(0.0, 1.0, pump);
   float val = mix(0.1, pow(snd + 0.2, 5.0), pump);//sin(time * 1.4 + v * u * 20.0) * 0.5 + 0.5;

   v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}