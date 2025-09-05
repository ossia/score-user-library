/*{
  "DESCRIPTION": "spectrum?",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/vsfaoEsuvT3yZrCRB)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 74,
    "ORIGINAL_DATE": {
      "$date": 1612795378172
    }
  }
}*/

// move your mouse off the code or click UI to hide it

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float aspect = resolution.x / resolution.y;
  float across = floor(sqrt(vertexCount) * aspect);
  float down = (vertexCount / across);

  float xId = mod(vertexId, across);
  float yId = floor(vertexId / across);

  float u = xId / (across - 1.0);
  float v = yId / (down - 1.0);

  float x = u * 2.0 - 1.0;
  float y = v * 2.0 - 1.0;

  gl_Position = vec4(x, y, 0, 1);

  float s = texture(sound, vec2(v * 0.5, 1.0 - u)).r;

  float hue = 0.8 + s * 0.4;
  float sat = 1.0;
  float val = s;

  gl_PointSize = max(resolution.x / across, resolution.y / down) * 2.;

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}