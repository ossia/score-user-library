/*{
  "DESCRIPTION": "synth",
  "CREDIT": "sail (ported from https://www.vertexshaderart.com/art/md47PJjYvynaWJqMy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 887,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.06274509803921569,
    0.10588235294117647,
    0.10588235294117647,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "floatSound", "TYPE": "audioFloatHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 156,
    "ORIGINAL_DATE": {
      "$date": 1622818509507
    }
  }
}*/

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float h = (sin(time/15.)*10. + 15.) + mod(2., time);

  float across = floor(vertexCount / h);

  float u = mod(vertexId, h);
  float v = mod(vertexId, across);
  float x = v / across - .5;

  float snd = texture(floatSound, vec2(v/across,u/5.)).a;

  float y = u / h * 6.5 + snd/100. - .5;

  gl_Position = vec4(x, y*.2-.5, 0, 1);
  gl_PointSize = 3.;
  vec3 c = vec3(v/across *.2+.2*sin(time+u/10.), 1.,.5);
  v_color = vec4(hsv2rgb(c),1);

}