/*{
  "DESCRIPTION": "Bodzin",
  "CREDIT": "jorenvo (ported from https://www.vertexshaderart.com/art/BsMpnBk6kQ8wK8mvy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 65536,
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
    "ORIGINAL_VIEWS": 5,
    "ORIGINAL_DATE": {
      "$date": 1557720109806
    }
  }
}*/

void main() {
  float size = floor(sqrt(vertexCount));

  vec2 c = vec2(mod(vertexId, size),
        floor(vertexId / size));

  // float loginess = 1.02;
  float ampl_sample_x = c.x;
  // ampl_sample_x = pow(loginess, ampl_sample_x) / pow(loginess, size);

  // divide by the maximum to normalize to [0, 1]
  float normalizer_x = size - 1.0;
  float normalizer_y = floor((vertexCount - 1.0) / size);
  c /= vec2(normalizer_x, normalizer_y);

  // no ampl past this
  const float FREQUENCY_NORMALIZE = .75;
  float sound_x = pow(c.x, 3.) * FREQUENCY_NORMALIZE;
  float ampl = texture(sound, vec2(sound_x, c.y)).r;
  vec3 color = vec3(ampl, 0, 0);

  // wide percussion
  /*
  const float WIDE_SAMPLES = 32.;
  float amplitude = 0.;
  for (float i = 0.; i < WIDE_SAMPLES; i++) {
    amplitude += texture(sound,
        vec2((i / WIDE_SAMPLES) * FREQUENCY_NORMALIZE, c.y)).a;
  }
  amplitude /= WIDE_SAMPLES;

  if (amplitude > .4) {
    color = vec3(0, 0, ampl);
  } else
  */
  if (ampl > .8) { // trigger
    const float TOTAL_S = 4.;
    const float HISTORIC_SAMPLES = 10.;
    const float HISTORIC_SAMPLE_TIME_S = .1;
    float sample_interval =
      TOTAL_S / HISTORIC_SAMPLE_TIME_S / HISTORIC_SAMPLES;

    float historic_ampl = 0.;
    for (float i = 1.; i <= HISTORIC_SAMPLES; i++) {
      historic_ampl += texture(sound,
        vec2(sound_x,
        c.y + i * sample_interval)).a;
    }

    historic_ampl /= HISTORIC_SAMPLES;

    // continuation
    if (historic_ampl > .3) {
      color = vec3(ampl, ampl, 0);
    }
  }

  // go from [0,1] -> [0,2]
  c *= 2.0;

  // go from [0,2] -> [-1, 1]
  c -= 1.0;

  gl_Position = vec4(c, 0, 1.);
  gl_PointSize = 10.;

  v_color = vec4(color, 1);
}