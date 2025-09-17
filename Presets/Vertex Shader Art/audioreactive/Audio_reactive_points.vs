/*{
  "DESCRIPTION": "Audio reactive points",
  "CREDIT": "der (ported from https://www.vertexshaderart.com/art/7ts7RJwsC7qRdn96W)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 5000,
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
    "ORIGINAL_VIEWS": 13,
    "ORIGINAL_DATE": {
      "$date": 1659707863365
    }
  }
}*/

void main() {
  float across = floor(sqrt(vertexCount));

  float x = mod(vertexId, across) / (across - 1.0) * 2.0 - 1.0;
  float y = floor(vertexId / across) / (across - 1.0) * 2.0 - 1.0;

  float dist = distance(vec2(x, y), vec2(0.0, 0.0));

  if(dist > 1.0) {
    return;
  }

  float aspect = resolution.y / resolution.x;

  gl_Position = vec4(x * aspect, y, 0.0, 1.0);

  float snd = texture(sound, vec2(0.0, dist)).r;

  gl_PointSize = 25.0 * pow(snd, 4.0);

  v_color = vec4(0.0, mix(0.3, 0.9, sin(time / 5.0) * 0.5 + 0.5), 1.0, 1.0);
}