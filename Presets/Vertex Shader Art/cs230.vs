/*{
  "DESCRIPTION": "cs230 - get_sound function get the sound_\ngl_position set position of points\ngl_PointSize control the size of points\nv_color set the color of points",
  "CREDIT": "\uc774\uc6d0\uc6a9 (ported from https://www.vertexshaderart.com/art/uvCsxPZo4fAnuhkrZ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Particles"
  ],
  "POINT_COUNT": 19999,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 107,
    "ORIGINAL_DATE": {
      "$date": 1554194464791
    }
  }
}*/


/*
Name: Lee Wonyong
Assignment 03 / shader
class: CS230
term: 2019 spring
*/
void main()
{
  float get_sound = texture(sound, vec2(mouse.x,mouse.y)).r;
  // get the sound value and insert it
  gl_Position = vec4(sin(get_sound)*mouse.x, cos(get_sound)*mouse.y,0 , abs(sin(get_sound*10.0)));
  // position of points, x , y , z , depth
  gl_PointSize = 100.0;
  // size of points
  v_color=vec4(abs(sin(get_sound)),abs(cos(get_sound)),abs(sin(get_sound)),1.0);
  // set color of points red, green, blue, alpha
}

