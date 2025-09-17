/*{
  "DESCRIPTION": "Audio Reactive_Own variation",
  "CREDIT": "chaerinpark (ported from https://www.vertexshaderart.com/art/5bpdGEqpAwiR35mDS)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 20000,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1684930658503
    }
  }
}*/

//Name : Chaerin Park
//Assignment : Exercise - Vertexshaderart : Audio Reactive
//Course : CS250
//Spring 2023

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
   float y = floor(vertexId / across);

   float u = x / (across - 1.0);
   float v = y / (across - 1.0);

   float ux = u * 2.0 - 1.0;
   float vy = v * 2.0 - 1.0;

   vec2 xy = vec2(ux, vy) * 1.3;

   float su = abs(u - 0.5) * 5.0;
   float sv = abs(v - 0.5) * 5.0;
   float au = abs(atan(su, sv)) / PI * 2.0;
   float av = length(vec2(su, sv));
   float snd = texture(sound, vec2(au * 0.5, av * 0.2)).r;

   gl_Position = vec4(xy, 0, 1);

   float soff = 0.0; //sin(time + x * y * 0.02) * 5.0;

   gl_PointSize = pow(snd + 0.2, 5.0) * 20.0 + soff;
   gl_PointSize *= 15.0 / across;
   gl_PointSize *= resolution.x / 600.0;

   float pump = step(0.5, snd);
   float hue = u * 0.1 + snd * 0.2 + time * 0.1; //sin(time + v * 20.0) * 0.05;
   float sat = mix(0.0, 1.0, pump);
   float val = mix(0.1, pow(snd + 0.2, 5.0), pump);

   v_color = vec4(hsv2rgb(vec3(hue, sat, val)).x + 0.5, 0.5, hsv2rgb(vec3(hue, sat, val)).y + 0.5, 0.7);
}