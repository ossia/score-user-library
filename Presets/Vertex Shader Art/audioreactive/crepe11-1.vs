/*{
  "DESCRIPTION": "crepe11",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/a2qkLCbs8jJyqJ4sJ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 95182,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.592156862745098,
    0.8980392156862745,
    0.7372549019607844,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 37,
    "ORIGINAL_DATE": {
      "$date": 1598789378587
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 100.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

void main() {
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float pointV = point / NUM_SEGMENTS;
  float circleId = floor(vertexId / NUM_POINTS);
  float numCircles = floor(vertexCount / NUM_POINTS);
  float circleV = circleId / numCircles;

  float snd = texture(sound, vec2(pointV * 0.0125, (1. - circleV) * 0.1)).r;

  float angle = pointV * PI * 2.0 +5.;
  float c = cos(angle) * mix(0.1, 1., circleV);
  float s = sin(angle) * mix(0.25, 0.5, circleV);

  float r = mix(0., PI, circleV) + pow(snd, 5.0);
  float rc = cos(r + sin(time * 4. + circleV * 4.));
  float rs = sin(r + sin(time * 4. + circleV * 4.));

  vec2 aspect = vec2(1, resolution.x / resolution.y) * 0.8;
  vec2 xy = vec2(
      rc * c + rs * s,
     -rs * c + rc * s);
  gl_Position = vec4(xy * aspect, 0, 1);

  float b = 1.0;
  v_color.a = 1.;
  v_color.rgb = vec3(1. - circleV, circleV, 1) * (1. - pow(snd, 20.0));

  gl_PointSize = 4.0;
  gl_PointSize *= resolution.x / 1600.0;
}