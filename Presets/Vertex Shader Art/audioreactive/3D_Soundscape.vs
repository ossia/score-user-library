/*{
  "DESCRIPTION": "3D Soundscape - Mapping sound to a 3D landscape generator",
  "CREDIT": "brendon (ported from https://www.vertexshaderart.com/art/WyifmdumQtSdpJgcb)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 29,
    "ORIGINAL_DATE": {
      "$date": 1524514153537
    }
  }
}*/

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.0);
  float v = y / (across - 1.0);

  float snd = texture(sound, vec2(u * y * 0.0001, v * 0.25)).r;

  float yOffset = pow(snd, 3.0);

  float ux = u * 2.0 - 1.0;
  float uy = v * 2.0 - 1.0 + yOffset - 0.75;

  vec2 xy = vec2(ux, uy) * 0.5;

  gl_Position = vec4(xy, 0.0, 1.0);
  gl_PointSize = 200.0 / across;

  float hue = v * u * pow(snd, 2.0);
  float sat = 1.0 + v * u * snd;
  float value = pow(snd + 0.25, 5.0);

  v_color = vec4(hsv2rgb(vec3(hue, sat, value)), 1);
}