/*{
  "DESCRIPTION": "foosh",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/PHjEAtNPJWshykNWj)",
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
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 38,
    "ORIGINAL_DATE": {
      "$date": 1466379446965
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

  float tm = time * 0.5 - ps * 0.8 * (sin(time + pu * 3. * pv * 4.) * 0.5 + 0.5);
  vec2 xy = vec2(
    pu * 2. - 1. + sin(tm + px * 0.1) * 0.1 + cos(tm * px * py * 0.000009) * 0.1,
    pv * 2. - 1. + sin(tm * 0.17 + py * 0.03) * cos(tm * 0.1 + px * 0.019) * 0.3
  );
  gl_Position = vec4(xy * 1.2, ps, 1);
  gl_PointSize = 2.0;

  float hue = (time * 0.01 + pu * .12);
  v_color = vec4(hsv2rgb(vec3(hue, 1, 0.7)), mix(0.9, 0., ps));
  v_color.rgb *= v_color.a;
}