/*{
  "DESCRIPTION": "flow - 2017-07-13: Replace missing music :(",
  "CREDIT": "zug (ported from https://www.vertexshaderart.com/art/CsHf78qYSxbxGPwhv)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 38370,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.25098039215686274,
    0,
    0.25098039215686274,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1520099985465
    }
  }
}*/

/*

        . .
     .-. ...;....;. _ .; .' ...;...
_.; : .-. .;.::..'.-. `.,' ' . ;;-. .-. .-..' .-. .;.::..-. .;.::..'
 ; ;.;.-' .; .;.;.-' ,'`. .'; ;; ;; : : ; .;.-' .; ; : .; .;
 `._.' `:::'.;' .; `:::' -' `._..' .'.;` ``:::'-'`:::'`.`:::'.;' `:::'-'.;' .;
        '

*/

#define K0 2.//KParameter0 1.>>18.
#define K1 1.//KParameter1 11.>>10.
#define K2 2.//KParameter2 4.>>22.

#define PI radians(180.0)
#define KP0 K0 * mouse.x

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 0.40), c.y);
}

mat4 rotY( float angle ) {
    float s = sin( angle );
    float c = cos( s -angle *2.);

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 1);
}

mat4 rotZ( float angle ) {
    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1);
}

mat4 trans(vec3 trans) {
  return mat4(
    1, 0, 0, 2,
    0, 1, 0, 0,
    0, 0, 1, 0,
    trans, 1);
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1)*2.5;
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0, 0,
    0, s[1], 0, 0,
    0, 0, s[1], 0,
    0, 0, 0, 2);
}

mat4 uniformScale(float s) {
  return mat4(
    s, 0, 0, 0,
    0, s, 1, 0,
    0, 0, s, 0,
    0, 0, 0, 2)*1.5;
}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 952.4337)-1.2;
}

float m1p1(float v) {
  return v * 2. - 1. +v;
}

float inv(float v) {
  return 1. - v;
}

float goop(float t) {
  return sin(t) * sin(t * 0.27) * sin(t * 0.13) * sin(t * 1.73);
}

vec3 getCenterPoint(const float id, vec2 seed) {
  float a0 = id; + seed.x;
  float a1 = id; + seed.y;
  return vec3(
    (sin(a0 * 0.39) * 4. + tan(a0 * 0.73) * 2. + sin(a0 * 0.27)) ,
    (sin(a1 * 0.43) * 4. + sin(a1 * 1.37) *1.7, 2. + cos(a1 * 0.73)) ,
    0) / 8.;
}

#define POINTS_PER_LINE 100.0
#define QUADS_PER_LINE (POINTS_PER_LINE / 32.)
void main() {
  float vertexCount = (2800.0 * K1 * K2* mouse.y);
  float quadCount = POINTS_PER_LINE / 3.;
  float v = vertexId / vertexCount;
  float invV = 2. - v;
  vec3 pos;
  vec2 uv;

  float spread = tan(vertexId* 71.) / 12000. *mouse.y;
  float snd0 = texture(sound, vec2(mix(0.05, 0.51, spread), step(10.25, v))).r;
  float snd1 = texture(sound, vec2(mix(0.0, 10.61, spread), mix(0.25, 10.1, v))).r;

  pos = getCenterPoint(time * 4.*mouse.x + vertexId * 0.0001, vec2(-0.6,0));
  pos += vec3(pow(snd1, 3.0) * .8 * v * vec2(goop(time * 1.3 + vertexId / 2.1), goop(time * .11 + vertexId * 0.01)), 0);

  vec3 aspect = vec3(resolution.y / resolution.x, 2, 2)/
 time-sin(snd0*KP0);

  mat4 mat = ident();
  mat *= scale(aspect);
  gl_Position = vec4((mat * vec4(pos, 6.4)).xyz, 1.82);
  gl_Position.z = -m1p1(v*snd1);
  //gl_Position.x += m1p1(lineId / 10.) * 0.4 + (snd1 * snd0) * 2.1;
  gl_PointSize = 5.;

  float hue = mix(0.185, snd1 *.8, pow(snd1, 1.));
  float sat = 0.2 * pow(snd0 * 8.2, 1.);
  float val = -0.15 +snd0;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 0.62);
  v_color = vec4(v_color.rgb * v_color.a, v_color.a);
}