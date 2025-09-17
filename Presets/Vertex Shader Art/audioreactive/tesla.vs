/*{
  "DESCRIPTION": "tesla",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/DBf3fehEcDfdz3dT7)",
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
    "ORIGINAL_VIEWS": 220,
    "ORIGINAL_DATE": {
      "$date": 1466623408780
    }
  }
}*/



// telsa

#define PI radians(180.)
#define NUM_POINTS_PER_GROUP 500.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float t2m1(float v) {
  return v * 2. - 1.;
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

  float to1 = sin(time * 0.11) * 0.5 + 0.5;
  float to2 = sin(time * 0.31) * 0.5 + 0.5;
  float snx = texture(sound, vec2(mix(0.001, 0.15, abs(atan(t2m1(pu), t2m1(pv + to1)))), ps * 0.05)).r;
  float sny = texture(sound, vec2(mix(0.015, 0.20, abs(atan(t2m1(pv + to2), t2m1(py)))), ps * 0.05)).r;

  float sx = snx * PI * 4. - 2. + -time * .1;
  //sx *= mix(1., -1., mod(groupId, 2.));
  sx += mix(0., sin(time * 0.1) * 3., mod(floor(groupId / 2.), 2.));
  float c = cos(sx);
  float s = sin(sx);

  float tm = time * 0.5 - ps * 0.8;
  //* (sin(time + pu * 3. * pv * 4.) * 0.5 + 0.5);
  vec2 xy = vec2(
    c * pow(sny + 0.1, 5.0),
    s * pow(sny + 0.1, 4.0)
// (snx * 2. - 1.) * 0.9, // + pu * 2. - 1. + sin(tm + px * 0.1) * 0.1 + cos(tm * px * py * 0.000009) * 0.1,
// (sny * 2. - 1.) * 0.9// + pv * 2. - 1. + sin(tm * 0.77 + py * 0.1) * cos(tm + px * 0.011) * 0.1
  ) * 1.5;
  gl_Position = vec4(xy * 1.2, ps, 1);
  gl_PointSize = 12.0 + snx * 0.;// + sin(time * px * py * 0.000001) * 10.;
  gl_PointSize *= resolution.x / 1600.;

  float hue = (time * 0.01 + pu * 0.4);
  v_color = vec4(hsv2rgb(vec3(hue, 1, 0.5)), mix(0.9, 0., ps));
  v_color.rgb *= v_color.a;
}