/*{
  "DESCRIPTION": "tm-grid",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/Fc6iHGcLDEtSTqbNG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 44009,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Touch", "NAME": "touch", "TYPE": "image" }, { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 337,
    "ORIGINAL_LIKES": 7,
    "ORIGINAL_DATE": {
      "$date": 1468376540034
    }
  }
}*/

/*

⬆ click [UI] and pick [⚪] then move the [🖱] mouse

*/

#define PI radians(180.0)

void main() {
  float numQuads = floor(vertexCount / 4.);
  float quadId = floor(vertexId / 4.);
  float down = floor(sqrt(numQuads));
  float across = floor(numQuads / down);

  float gx = mod(quadId, across);
  float gy = floor(quadId / across);

  float vId = mod(vertexId, 4.);

  float x = gx + mod(vId, 2.) - step(3., vId);
  float y = gy + step(3., vId);

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(x, y) / vec2(across, down) * 2. - 1.;

  vec2 sp = xy * 1.1;

  const int count = 60;
  for (int i = 0; i < count; ++i) {
    float iv = 1. - float(i) / float(count - 1);
    float hist = (float(i) + 0.5) / IMG_SIZE(sound).y;
    vec2 m = texture(touch, vec2(0, hist)).xy;
    vec2 dm = m - sp;
    float dist = length(dm);
    float effect = mix(1., 0., clamp(dist * 5., 0., 1.));
    sp = sp - dm * pow(abs(effect), 2.5) * 1. * pow(iv, 2.);
  }

  float ang = fract(time * 0.1 + abs(atan(sp.x, sp.y) / PI));
  float rad = length(sp);
  float snd = texture(sound, vec2(mix(0.001, 0.030, ang), rad * 0.2)).r;

  sp += pow(snd, 5.) * 0.025;

  gl_Position = vec4(sp, 0, 1);

  float pump = step(mix(1., 0.8, ang), snd);

  v_color = vec4(vec3(mix(0.1, 1., pow(snd, 5.))), 1);

  v_color = mix(v_color, vec4(1,0,0,1), pump);
}