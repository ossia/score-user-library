/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "megaloler (ported from https://www.vertexshaderart.com/art/CxkapDDzkpTBvHykF)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 4240,
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
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1528904643703
    }
  }
}*/

#define PI radians(180.)
#define TAU radians(360.)
void main() {

  float aspect = resolution.x / resolution.y;
  float width = aspect * 2.;

  float across = vertexCount;
  float id = vertexId;
  float rawX = id / across;
  float x = rawX * width - aspect;
  float amp0 = texture(sound, vec2(0., 0.)).r;
  float amp = texture(sound, vec2(mix(0., 0.75, rawX), 0.)).r;
  float freq = pow(x / 5., mix(amp0, 2., 3.0));
  float y = sin((x + time) * PI * freq) * amp;

  gl_Position = vec4(x/aspect, y, 0, 1);
  v_color = vec4(1, 1, 1, 1);
}