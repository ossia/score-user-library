/*{
  "DESCRIPTION": "yellolong",
  "CREDIT": "jarredthecoder (ported from https://www.vertexshaderart.com/art/a3JBo24QkPxvKYpja)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 61995,
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
    "ORIGINAL_VIEWS": 62,
    "ORIGINAL_DATE": {
      "$date": 1669434220197
    }
  }
}*/

void main()
{
  float vc = vertexCount / 11.;

  float x = mod(vertexId, vc);
  float y = floor(vertexId / vc);

  float u = x / vc;
  float v = y / vc;

  float ux = u * 2. - 1.;
  float vy = y * 2. - 1.;

  float snd = texture(sound, vec2(ux, vy)).r;

  gl_PointSize = 50.0;
  gl_Position = vec4(ux,vy-snd,0.5,1);
  v_color = vec4(10,5,0,1);
}