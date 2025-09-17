/*{
  "DESCRIPTION": "shader template, sound variable",
  "CREDIT": "floppafilms google emails (ported from https://www.vertexshaderart.com/art/BKz7wnibraTYy2v8H)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Animated"
  ],
  "POINT_COUNT": 28423,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 8,
    "ORIGINAL_DATE": {
      "$date": 1713504707010
    }
  }
}*/

/*
V V SSSSSS A
 V V S A A
  V V S A A
   V V S AAAAAAA
    V SSSSS A A

vsa is awesome

*/

void main() {
 vec3 cameraEyeVec = vec3(0,0,0);
   float snd = texture(sound,vec2(mix(0.1,0.25,time),(vertexId/vertexCount)*.2)).r;
   v_color = vec4(1,snd,0,1);
}