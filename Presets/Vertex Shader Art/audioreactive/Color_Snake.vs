/*{
  "DESCRIPTION": "Color Snake",
  "CREDIT": "8bitrick (ported from https://www.vertexshaderart.com/art/mr5e8wZkAskGjnL8z)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 2333,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1555370014731
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 21.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float bins = 10.;
  float bin_horz_offset = 0.7;
  float point_min = 0.;
  float point_max = 30.;
  float percent_count = vertexId / vertexCount;
  float vert_bin = floor(percent_count * bins) / max(1. ,(bins - 1.));
  float bin_eps = fract(percent_count * bins) / max(1. ,(bins - 1.));
  //float freq = (vertexId / (vertexCount - 1.)) * 0.6 + 0.1;
  //float freq = (vert_bin) * 0.6 + 0.1;
  float freq = (vert_bin) + bin_eps;// * 0.6 + 0.1;

  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float offset = count * 0.02;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = 0.2;
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = count * 0.01;
  float oC = cos(orbitAngle + time * count * 0.01) * sin(orbitAngle);
  float oS = sin(orbitAngle + time * count * 0.01) * sin(orbitAngle);

  float bin_offset = (vert_bin * 2. - 1.) * bin_horz_offset;
  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c + bin_offset,
      oS + s);
  //gl_Position = vec4(xy * aspect + mouse * 0.1, 0, 1);
  gl_Position = vec4(xy * aspect, 0, 1);

  float hue = (time * 0.01 + count * 1.001);
  float hue2 = vert_bin;

  float intensity = texture(sound,vec2(freq,0.)).r;
  float size = pow(intensity, 3.);
  gl_PointSize = mix(point_min, point_max, size);
  //gl_Position = vec4(x,y,0,1);
  //v_color = mix(vec4(hsv2rgb(vec3(0.25, fract(time+row_per), 1.)), 1.-row_per), background, row_per - 0.2);
  v_color = vec4(hsv2rgb(vec3(hue2, 1, 1)), 1);
}