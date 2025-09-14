/*{
  "DESCRIPTION": "sound basics 1",
  "CREDIT": "mv10 (ported from https://www.vertexshaderart.com/art/bpX9tBkNhHiF6nHk8)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Particles"
  ],
  "POINT_COUNT": 15000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Volume", "NAME": "volume", "TYPE": "audioFloatHistogram" }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 98,
    "ORIGINAL_DATE": {
      "$date": 1687710770852
    }
  }
}*/


// use about 15000 points

// white = sound texture
// green = volume texture

// very long playlist:
// https://soundcloud.com/owen-fullerton-1/sets/dj-icey-dj-baby-anne-move

void main () {

  // normalize the ID; 0.0 to 1.0 across the range of input IDs
  float norm = (vertexId / vertexCount);

  // expand x position to cover entire display area
  // we're shifting norm 0.0 to 1.0 to cover display -1.0 to +1.0
  // mathematically identical: norm * 2.0 - 1.0
  float x = (norm - 0.5) * 2.0;

  // sample the texture history data (0.0 to 1.0 via norm)
  // this will be the point's y-pos with offsets to separate them
  // note the first array index is frequency; x=0.0 is all bass-driven
  float ySnd = (texture(sound, vec2(0.0, norm)).r - 0.3);
  float yVol = (texture(volume, vec2(0.0, norm)).r - 0.7);

  // even/odd IDs alternate between textures and colors
  // it would be more readable and flexible to do this with arrays
  // but WebGL can't handle variable array indexing (yeah WTF?)
  // https://stackoverflow.com/a/30648046/152997
  float a = mod(vertexId, 2.0);
  float b = step(a, 0.0);

  // one y is multiplied by 1, the other is multiplied by 0
  float y = (ySnd * a) + (yVol * b);

  // same for colors, while = sound tex, green = volume tex
  vec3 color = (vec3(1.0) * a) + (vec3(0.0, 1.0, 0.0) * b);

  gl_Position = vec4(x, y, 0.0, 1.0);
  v_color = vec4(color, 1.0);

  // fat points easier to see at hi-res full-screen
  gl_PointSize = 5.0;

}