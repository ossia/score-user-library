/*{
  "DESCRIPTION": "frequency FX",
  "CREDIT": "mv10 (ported from https://www.vertexshaderart.com/art/3hP9SNbDTX5RFMHT5)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 65000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Volume", "NAME": "volume", "TYPE": "audioFloatHistogram" }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 21,
    "ORIGINAL_DATE": {
      "$date": 1687724846809
    }
  }
}*/

// very long playlist:
// https://soundcloud.com/owen-fullerton-1/sets/dj-icey-dj-baby-anne-move

vec3 hsv2rgb(vec3 c)
{
    c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main () {

  float norm = (vertexId / vertexCount);
  float x = (norm - 0.5) * 2.0;

  float freq = norm * 0.2 + 0.004;
  float y = (texture(sound, vec2(freq, 0.0)).r - 0.5);

  float vol = texture(volume, vec2(0.0, 0.0)).a * 2.0;
  vec3 hsv = vec3(vol, 1.0, 1.0);

  gl_Position = vec4(x, y, 0.0, 1.0);
  v_color = vec4(hsv2rgb(hsv), 1.0);

  gl_PointSize = 5.0;

}