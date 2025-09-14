/*{
  "DESCRIPTION": "mouse-wip",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/C4gCacp8eQ337rdFD)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 90773,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0.01568627450980392,
    0.023529411764705882,
    0.058823529411764705,
    1
  ],
  "INPUTS": [ { "LABEL": "Touch", "NAME": "touch", "TYPE": "image" }, { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 83,
    "ORIGINAL_DATE": {
      "$date": 1623655178262
    }
  }
}*/

// ==========================================
// ^
// |
// +-- click "hide" then MOVE YOUR MOUSE!!!!
// ==========================================

//KDrawmode=GL_TRIANGLES

#define radiusParam0 0.10//KParameter 0.03>>0.3
#define radiusParam1 0.82//KParameter 0.>>1.
#define angleParam0 0.02//KParameter 0.>>1.
#define sndFactor 0.8//KParameter 0.>>1.
#define PointSizeFactor 0.18//KParameter 0.>>1.
#define kpx 0.160//KParameter 1.>>8.

#define HPI 1.570796326795
#define PI 3.1415926535898

//KverticesNumber=233333

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float u = 0.0;
  float v = fract(vertexId / 240.0);
  float age = floor(vertexId / 240.0) / 240.0;
  float invAge = 1.0 - age;
  vec4 touch = texture(touch, vec2(u, v));
  float snd = texture(sound, vec2(v, age) * vec2(0.25, 0.25)).r;
  float t = time - touch.w;

  float a = mod(vertexId, 6.0) / 6.0 * PI * 2.0 + t * 100.0;
  vec2 cs = vec2(cos(a), sin(a));
  vec2 xy = vec2(touch.xy) + (cs * age * snd * 0.2 *asin(kpx/3. )- 0.21) * 0.1;
  gl_Position = vec4(xy * (1.0 + (age + t) * 1.0) , age, 1);

  float hue = mix(age + 0.6*kpx + sin(v * PI * 2.0) * 0.9, 0.0, touch.z);
  vec3 color = hsv2rgb(vec3(hue, invAge, snd + touch.z));
  v_color = vec4(mix(color, background.rgb, age)-sin(color*.18) * invAge, invAge);
  gl_PointSize = mix(20.0, 1.0, age);

}

