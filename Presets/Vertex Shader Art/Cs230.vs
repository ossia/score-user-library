/*{
  "DESCRIPTION": "Cs230 - moving with music\n& change color with mouse\nposition",
  "CREDIT": "\ub3c4\uc601 (ported from https://www.vertexshaderart.com/art/8jiF9r8CqR46bXvXM)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 5000,
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
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1554199133048
    }
  }
}*/


void main()
{
   float value = vertexId*10.0;

 float x =mouse.x;
 float y = mouse.y;

  float snd = texture(sound, vec2(0, 0)).r;
   gl_Position = vec4(cos(value), sin(value), 0, abs(snd*2.0));

   gl_PointSize = 50.0;

   v_color = vec4(cos(x), sin(y), tan(x*y), 1);
}

