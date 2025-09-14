/*{
  "DESCRIPTION": "t-grid",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/YXfLo5Yw55muQ7MZn)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 15238,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Touch", "NAME": "touch", "TYPE": "image" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 97,
    "ORIGINAL_DATE": {
      "$date": 1468375901068
    }
  }
}*/

#define PI radians(180.)

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

  vec2 sp = xy * aspect * 1.1;

  const int count = 60;
  for (int i = 0; i < count; ++i) {
    float iv = 1. - float(i) / float(count - 1);
    vec2 m = texture(touch, vec2(0, (float(i) + 0.5) / IMG_SIZE(sound).y)).xy;

    vec2 dm = m - sp;
    float dist = length(dm);
    float effect = mix(1., 0., clamp(dist * 3., 0., 1.));
    sp = sp - dm * pow(abs(effect), 2.5) * 0.5 * pow(iv, 5.);
  }

  gl_Position = vec4(sp, 0, 1);

  v_color = vec4(vec3(0), 1);
}