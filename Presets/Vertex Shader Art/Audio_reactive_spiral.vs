/*{
  "DESCRIPTION": "Audio reactive spiral",
  "CREDIT": "der (ported from https://www.vertexshaderart.com/art/j99N9DxvqWDcDFv84)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 79575,
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
    "ORIGINAL_VIEWS": 15,
    "ORIGINAL_DATE": {
      "$date": 1659754785453
    }
  }
}*/

//From VertexShaderArt Boilerplate Library: https://www.vertexshaderart.com/art/qjkP6BDvEFyD6CfZC
mat4 uniformScale(float s) {
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
    0, 0, 0, 1);
}

void main() {
  float angle = vertexId / 1000.0;
  float radius = vertexId / 80000.0;

  float drums = texture(sound, vec2(0.55, 0.0)).r / 3.0 + 1.0;

  float aspect = resolution.y / resolution.x;

  gl_Position = uniformScale(drums) * vec4(cos(angle) * radius * aspect, sin(angle) * radius, 0.0, 1.0);

  float snd = texture(sound, vec2(0.55, vertexId / vertexCount)).r;

  float pump = 1.0 + step(0.1, snd);

  gl_PointSize = 1.0 + pump * mix(0.0, 10.0, snd);

  v_color = vec4(mix(0.2, 1.0, sin(time / 2.0) * 0.5 + 0.5), 0.7, 1.0, 1.0);
}