/*{
  "DESCRIPTION": "mindmagma01 - tut - Based on tutorials by vertexshaderart",
  "CREDIT": "sherrysmcguire (ported from https://www.vertexshaderart.com/art/XMfocB69HDJbjh5Sf)",
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
    0.25882352941176473,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1691353537203
    }
  }
}*/

// music track: https://soundcloud.com/graham-panter/fly-by-light
// mcguirev10: very long playlist:
// https://soundcloud.com/owen-fullerton-1/sets/dj-icey-dj-baby-anne-move

// from: http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#define PI radians(180.0)

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float xoff = 0.0; //sin(time + y * 0.2) * 0.1;
  float yoff = 0.0; //sin(time * 1.1 + x * 0.3) * 0.2;

  float ux = u * 2.0 - 1.0 + xoff;
  float vy = v * 2.0 - 1.0 + yoff;

  vec2 xy = vec2(ux, vy) * 1.3;

  float su = abs(u - 0.5) * 2.0;
  float sv = abs(v - 0.5) * 2.0;
  float au = abs(atan(su, sv)) / PI;
  float av = length(vec2(su, sv));
  float snd = texture(sound, vec2(au * 0.05, av * 0.25)).r;

  gl_Position = vec4(xy, 0, 1);

  float soff = 0.0; //sin(time * 1.2 + x * y * 0.2) * 5.0;

  gl_PointSize = pow(snd + 0.2, 5.0) * 30.0 + soff;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;

  float pump = step(0.8, snd);
  float hue = u * 0.1 + snd * 0.2 + time * 0.1; //sin(time + v * 20.0) * 0.05;
  float sat = mix(0.0, 1.0, pump); //mix(1.0, -10.0, av);
  float val = mix(0.1, pow(snd + 0.2, 5.0), pump); //sin(time + v * u * 20.0) * 0.5 + 0.5;

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);

}