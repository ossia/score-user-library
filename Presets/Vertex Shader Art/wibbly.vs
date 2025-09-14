/*{
  "DESCRIPTION": "wibbly",
  "CREDIT": "jan-ale (ported from https://www.vertexshaderart.com/art/RkZ8yDec9HRBYHmvX)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100,
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
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1671841309508
    }
  }
}*/

void main() {
  float size = 10.;
  float xPos = mod(vertexId/size,1.);
  xPos *= 2.;
  xPos -= 1.;
  float yPos = vertexId/size;
  yPos = floor(yPos);
  yPos /= size;
  yPos *= 2.;
  yPos -= 1.;

  float volume = texture(sound, vec2(0., time)).r;
  xPos += 0.3 * mix(-volume, volume, mod(5.*yPos,2.));

  gl_Position = vec4(xPos, yPos, 0., 1.);
  gl_PointSize = 10. * volume;
  vec3 col = sin(time+vec3(0.,2.,4.));
  v_color = vec4(col, 1.);
}