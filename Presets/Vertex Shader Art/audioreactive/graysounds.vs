/*{
  "DESCRIPTION": "graysounds",
  "CREDIT": "jarredthecoder (ported from https://www.vertexshaderart.com/art/JoWAeXNsfz23C8d8b)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 5081,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.47843137254901963,
    0.47843137254901963,
    0.47843137254901963,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 42,
    "ORIGINAL_DATE": {
      "$date": 1669288333230
    }
  }
}*/

#define NUM 15.0

void main() {
  gl_PointSize = 74.6;
  float a = mod(vertexId, NUM * 1.0);
  float b = mod(floor(vertexId / NUM), NUM * 1.0);
  float xax = a / NUM * 2.0 - 1.0;
  float yax = b / NUM * 2.0 - 1.0;
  gl_Position = vec4(xax, yax, 0, 1);
  v_color = vec4(pow(texture(sound,vec2(xax,yax)).r,8.0));
}