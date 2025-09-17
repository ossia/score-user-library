/*{
  "DESCRIPTION": "simple",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/W5AaXFFJk2ZggnWEk)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
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
    "ORIGINAL_VIEWS": 107,
    "ORIGINAL_DATE": {
      "$date": 1551118150645
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
  float u = vertexId / (vertexCount - 1.);
  float x = u * 2. - 1.;
  float s = texture(sound, vec2(u, 0.)).r;
  float y = s * 2. - 1.;

  gl_Position = vec4(x, y, 0, 1);

  float hue = u;
  float sat = 1.0;
  float val = 1.;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}