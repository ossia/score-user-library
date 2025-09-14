/*{
  "DESCRIPTION": "sound,floatSound,volumn",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/sgg5X7iFw5d2SLzwX)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
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
  "INPUTS": [ { "LABEL": "Volume", "NAME": "volume", "TYPE": "audioFloatHistogram" }, { "LABEL": "Sound", "NAME": "floatSound", "TYPE": "audioFloatHistogram" }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1687830435016
    }
  }
}*/

// very long playlist:
// https://soundcloud.com/owen-fullerton-1/sets/dj-icey-dj-baby-anne-move

// lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c)
{
    c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main () {

  float freq = vertexId / vertexCount;
  float s = texture(sound, vec2(freq, 0.0)).r - 0.5;
  float v = texture(volume, vec2(0, 0.0)).a - 0.5;
  float f = texture(floatSound, vec2(freq, 0.0)).a * 0.01 + 0.5;

  float id = mod(vertexId, 3.0);
  float y0 = mix(s, v, step(0.5, id));
  float y = mix(y0, f, step(1.5, id));

  float x = freq * 2.0 - 1.0;

  vec3 hsv = vec3(vertexId / 3.0, 1.0, 1.0);
  gl_Position = vec4(x, y, 0.0, 1.0);
  v_color = vec4(hsv2rgb(hsv), 1.0);

  gl_PointSize = 5.0;

}