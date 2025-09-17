/*{
  "DESCRIPTION": "lingeometry",
  "CREDIT": "\u512a\u6597 (ported from https://www.vertexshaderart.com/art/fxwcEhippPALwji4k)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 200,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0.15294117647058825,
    0.15294117647058825,
    0.15294117647058825,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1534093939914
    }
  }
}*/

#define PI radians(90.0)
#define NUM_SEGMENTS 50.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 3.0
//#define FIT_VERTICAL

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  gl_PointSize = resolution.x / 40.0 ;
  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS) * time;
  float count = floor(vertexId / NUM_POINTS) + sin(-time);
  float offset = count * .0002;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = 0.2;
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle = count * 0.01;
  float r2 = sin(orbitAngle);
  float oC = cos(orbitAngle + time * count * 0.01) * r2;
  float oS = sin(orbitAngle + time * count * 0.01) * r2;

  #ifdef FIT_VERTICAL
    vec2 aspect = vec2(resolution.y / resolution.x, 1);
  #else
    vec2 aspect = vec2(1, resolution.x / resolution.y);
  #endif

  vec2 xy = vec2(
      oC + c,
      oS + s);

  float dd = length(xy);
  float snd = pow(texture(sound, vec2(fract(count * 0.01) * 0.125, dd * 0.1)).r, .1);

  xy = xy + xy * snd ;
  gl_Position = vec4(xy * aspect + mouse * 0.1, -fract(count * 10. * time), 1);

  float hue = (time * 0.01 + count);
  v_color = vec4(mix(hsv2rgb(vec3(hue + snd, 1, 1)), vec3(1,1,1), snd), 0.1 + snd * 0.5);
  v_color = vec4(v_color.rgb + abs(sin(time) * cos(time)) + abs(dot(cos(time), sin(time))) * v_color.a, v_color.a);
}