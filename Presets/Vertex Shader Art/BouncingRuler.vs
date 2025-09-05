/*{
  "DESCRIPTION": "BouncingRuler",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/prW9D82SGpoazGXyC)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 48,
    "ORIGINAL_DATE": {
      "$date": 1694082641022
    }
  }
}*/


void main() {

  vec2 xy = vec2(0.0,0.0);

  if (vertexId < 2.0) {
   xy = vec2(vertexId - 0.5,0.0);
  } else {
    xy = vec2(vertexId/100.0 - 0.5, mod(vertexId, 2.0) - 0.5 );

    float s = texture(sound, (xy+ vec2(0.5,0.5))*0.2).r;
    xy.y +=s;

  }

  gl_Position = vec4(xy * 0.5, 0, 1);

  v_color = vec4(1.0,1.0,1.0,1.0)
}