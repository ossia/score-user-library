/*{
  "DESCRIPTION": "gridpop",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/ssKvHBoYZGXuj88en)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 1156,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.8901960784313725,
    0.40784313725490196,
    0.00784313725490196,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 61,
    "ORIGINAL_DATE": {
      "$date": 1669347151963
    }
  }
}*/

void main()
{
  float down = floor(sqrt(vertexCount));
  float ac = floor(vertexCount / down);

  float x = mod(vertexId, ac);
  float y = floor(vertexId / ac);

  float u = x / (ac - 1.);
  float v = y / (ac - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  float snd = pow(texture(sound, vec2(u * 0.01, v * 0.01)).r, 4.);

  gl_Position = vec4(ux, vy, 0, 1);
  gl_PointSize = 25.5 * snd + 2.0;
  v_color = vec4(1, 0, 0, 1);
}