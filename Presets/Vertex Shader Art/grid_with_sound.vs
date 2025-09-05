/*{
  "DESCRIPTION": "grid_with_sound - main",
  "CREDIT": "moon-jong (ported from https://www.vertexshaderart.com/art/fM43AivGvoEWBm7G7)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 2426,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.050980392156862744,
    0.047058823529411764,
    0.047058823529411764,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1679925724817
    }
  }
}*/

void main() {

   float down = floor(sqrt(vertexCount));
 float across = floor(vertexCount / down);
   float x = mod(vertexId, across);
   float y = floor(vertexId / across);

   float u = x / (across - 1.);
   float v = y / (across - 1.);

   float xoff = sin(time + y * 0.2) * 0.1;
  float yoff = cos(time + x * 0.3) * 0.2;
   float soff = sin(time + x) * 5.;

   float ux = u * 2. - 1. + xoff;
    float vy = v * 2. - 1. + yoff;

   vec2 xy = vec2(ux, vy) * 1.3;

 gl_Position = vec4(xy, 0, 1);
   gl_PointSize = 15.0 + soff;
 gl_PointSize *= 20.0 / across;

   float snd = texture(sound, vec2(ux, ux)).r;
   gl_PointSize *= resolution.x / 600. + snd;

 v_color = vec4(0.5 + snd, 0.2 + snd, 1. + snd , 1);

}