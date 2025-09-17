/*{
  "DESCRIPTION": "eh - ooo",
  "CREDIT": "floppafilms google emails (ported from https://www.vertexshaderart.com/art/NdqnSLhc6EZ67TXkP)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1024,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 19,
    "ORIGINAL_DATE": {
      "$date": 1713478374197
    }
  }
}*/

mat2 rot(float a) {
  float s=sin(a), c=cos(a);
  return mat2(c,s,-s,c);
}

void main() {
  float a = 4. * 6.283185307179586 * vertexId / vertexCount;

  float r = 3.25;
  float s = texture(sound, vec2(mix(0.01, 0.02, 0.03), 0.)).r;
  vec2 off = vec2(0.5 * sin(r*a) + 1., cos(r*a));
  vec3 p = vec3(sin(a), 1, cos(a)) * off.xyx;

  p.xz *= rot(time);
  p.yz *= rot(0.8);

  gl_Position = vec4(p/(p.z+3.), 1);
  v_color = vec4(1./(p.z+2.),s,0,1);
}