/*{
  "DESCRIPTION": "POTATO - aetaewt",
  "CREDIT": "jko (ported from https://www.vertexshaderart.com/art/5eLB8us5zfTRPWx49)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 6,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1552913242796
    }
  }
}*/



void main() {
   float id = vertexId;

   float ux = floor(id / 6.); + mod(id, 2.);

    float x = 0.;
    float y = 0.;

  vec2 xy = vec2(x, y);

   gl_Position = vec4(xy, 0,1);

   v_color = vec4(0,0,1,1);

}

#if 0
void main() {
 float down = floor(sqrt(vertexCount));
    float across = floor (vertexCount / down);

    float x = mod(vertexId, across);
    float y = floor(vertexId / across);

    float u = x / (across - 1.);
    float v = y / (across - 1.);

  float snd = texture(sound, vec2(u, 0)).r;
   float mod3 = snd;

    float xoff = sin(time*0.8 + y*0.2) * 0.1;
    float yoff = cos(time*0.1 + x* 0.5) * 0.1;https://soundcloud.com/ukf/current-value-phace-thump

    float ux = (u * 2. - 1. + snd * 0.1) + xoff;
    float uy = v * 2. - 1.+ snd * 0.1 + yoff;

    gl_Position = vec4(ux * 1.4, uy * 1.4, 0 , 1);

    float soff = cos(time + x / 10. - y * 0.1)*20.;

    gl_PointSize = 20. + soff;
    gl_PointSize *= 20. / across;
    gl_PointSize *= resolution.x / 600.;

 // ----------------- COLOUR ----------------- //
    float mod1 = sin(0.2 + time) * 0.4 ;
    float mod2 = sin(time + 0.3*y + 0.2)*0.4;

    v_color = vec4(mod1 + 0.4,mod3, mod2 + 0.4 + mod3,0. + mod3);

}
#endif
