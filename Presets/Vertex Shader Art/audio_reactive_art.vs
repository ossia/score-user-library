/*{
  "DESCRIPTION": "audio reactive art - variation",
  "CREDIT": "taejukwon-digipen (ported from https://www.vertexshaderart.com/art/Nv4BapXAuEeZYTdNe)",
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
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1653482890661
    }
  }
}*/

//Taeju Kwon
//CS250
//2022_Spring
//04_AudioReactiveArt

vec3 hsv2rgb(vec3 c)
{
  c = vec3 (c.x, clamp(c.yz, 0.0,1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p-K.xxx , 0.0, 1.0) , c.y);
}

#define PI radians(180.0)

void main()
{
 float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount/down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = 0.;//sin(time + y * 0.2) * 0.1;
  float yoff = 0.;//sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  float sv = abs(v-0.9) * 3.;
  float su = abs(u-0.9) * 3.;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2(au* .05,av * .25)).r;

  gl_Position = vec4(xy, 0,1);

  float soff = 0.; //sin(time + x * y * 0.02) * 5.;

  gl_PointSize = pow(snd + 0.1, 5.)* 30.0 + soff;
  gl_PointSize += 20. / across;
  gl_PointSize += resolution.x / 600.;

  float hue = u * .3 + snd * .1 + time * .2; //u * 1. + sin(time + v * 20.) * 0.05;
  float sat = mix(0.,1.,1.);
  float val = mix(-1.,pow(snd + 0.2, 5.), 1.5); //sin(time + v * u * 20.0 ) * .5 + .5;

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)),1);
}
