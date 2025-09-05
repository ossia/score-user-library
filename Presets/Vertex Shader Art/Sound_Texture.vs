/*{
  "DESCRIPTION": "Sound Texture",
  "CREDIT": "gaz (ported from https://www.vertexshaderart.com/art/fvQbw8FtZzmvQG4Wz)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 439,
    "ORIGINAL_LIKES": 4,
    "ORIGINAL_DATE": {
      "$date": 1459091756933
    }
  }
}*/

void main() {
  float aspect = resolution.x / resolution.y;
  vec2 dim = floor(vec2(sqrt(vertexCount*aspect) ,sqrt(vertexCount/aspect)));
  vec2 p = vec2(mod(vertexId, dim.x), mod(floor(vertexId/ dim.x),dim.y));
  p /= dim;
  p = p * 2.0 - 1.0;
  gl_Position = vec4(p, 0.0, 1.0);
  gl_PointSize=resolution.y / dim.y;
  //p.x *= aspect;
  vec3 col = texture(sound, p * 0.5 + 0.5).rgb;
  v_color = vec4(col, 1.0);
}