/*{
  "DESCRIPTION": "ropepull",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/ko66wgrdNeNbx9WDz)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 31941,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    0.9176470588235294,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 73,
    "ORIGINAL_DATE": {
      "$date": 1669348882170
    }
  }
}*/

#define NUM 1.

void main() {
  float down = floor(sqrt(vertexCount));
  float a = mod(vertexCount, down);
  float cad = a + down / NUM;

  float x = mod(vertexId, NUM);
  float y = floor(vertexId / NUM);

  float u = x * NUM / cad;
  float v = y * NUM / cad;

  float ux = u * 5.0 / cad;
  float vy = v * 2.0 / cad;

  float snd = pow(texture(sound, vec2(ux * 0.01, vy * 0.01)).r, 4.);

  gl_PointSize = 10.0;

  gl_Position = vec4(x / cad + snd, y / cad, 4.9, 5);

  v_color = vec4(1, 2, 4, 5);
}