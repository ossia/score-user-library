/*{
  "DESCRIPTION": "sloosh",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/xG6tZRJFAL9i7pWED)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 150,
    "ORIGINAL_DATE": {
      "$date": 1466621736006
    }
  }
}*/

#define PI radians(180.)
#define NUM_POINTS_PER_GROUP 30.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float groupId = floor(vertexId / NUM_POINTS_PER_GROUP);
  float pointId = mod(vertexId, NUM_POINTS_PER_GROUP);
  float ps = pointId / NUM_POINTS_PER_GROUP;
  float numGroups = floor(vertexCount / NUM_POINTS_PER_GROUP);
  float down = floor(sqrt(numGroups));
  float across = floor(numGroups / down);

  float px = mod(groupId, across);
  float py = floor(groupId / across);
  float pu = px / across;
  float pv = py / down;

  float t = time + 9500.0;
  float snd = texture(sound, vec2(pu * 0.01, abs(pv * 2. - 1.) * 0.4)).r;
  float tm = t * 0.5 - ps * 0.8 * (sin(t + pu * 3. * pv * 4.) * 0.5 + 0.5);
  vec2 xy = vec2(
    pu * 2. - 1. + sin(tm + px * 0.1) * 0.1 + cos(tm * px * py * 0.000009) * 0.1,
    pv * 2. - 1. + sin(tm * 0.77 + py * 0.1) * cos(tm + px * 0.011) * 0.1
  );
  gl_Position = vec4(xy * 1.2, ps, 1);
  gl_PointSize = 2.0 + sin(time * px * py * 0.001) * 40.;
  gl_PointSize *= resolution.x / 1600.;

  float hue = (time * 0.01 + pu * 0.1 + pow(snd, 5.) * .2);
  v_color = vec4(hsv2rgb(vec3(hue, mix(0.5, 1.0, pow(snd, 5.)), 0.25 + pow(snd, 10.0) * 0.5)), mix(0.9, 0., ps));
}