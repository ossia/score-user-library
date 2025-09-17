/*{
  "DESCRIPTION": "flow",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/XxN2enyHa2MMbayT5)",
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
    0.2980392156862745,
    0.2235294117647059,
    0.7254901960784313,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 40,
    "ORIGINAL_DATE": {
      "$date": 1643992183076
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

#define PI radians(180.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat4 rotY( float angle ) {
    float s = sin( angle );
    float c = cos( angle );

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
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    trans, 1);
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0, 0,
    0, s[1], 0, 0,
    0, 0, s[2], 0,
    0, 0, 0, 1);
}

mat4 uniformScale(float s) {
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
    0, 0, 0, 1);
}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

float m1p1(float v) {
  return v * 2. - 1.;
}

float inv(float v) {
  return 1. - v;
}

float goop(float t) {
  return sin(t) * sin(t * 0.27) * sin(t * 0.13) * sin(t * 0.73);
}

vec3 getCenterPoint(const float id, vec2 seed) {
  float a0 = id; + seed.x;
  float a1 = id; + seed.y;
  return vec3(
    (sin(a0 * 0.39) * 4. + sin(a0 * 0.73) * 2. + sin(a0 * 0.27)) ,
    (sin(a1 * 0.43) * 4. + sin(a1 * 0.37) * 2. + cos(a1 * 0.73)) ,
    0) / 8.;
}

#define POINTS_PER_LINE 1800.0
#define QUADS_PER_LINE (POINTS_PER_LINE / 6.)
void main() {
  float quadCount = POINTS_PER_LINE / 6.;
  float v = vertexId / vertexCount;
  float invV = 1. - v;
  vec3 pos;
  vec2 uv;

  float spread = mod(vertexId, 100.) / 100.;
  float snd0 = texture(sound, vec2(mix(0.05, 0.051, spread), mix(0.25, 0., v))).r;
  float snd1 = texture(sound, vec2(mix(0.06, 0.061, spread), mix(0.25, 0., v))).r;

  pos = getCenterPoint(time * 4. + vertexId * 0.0001, vec2(0,0));
  pos += vec3(pow(snd1, 3.0) * .8 * v * vec2(goop(time * 10.3 + vertexId * 0.01), goop(time * 5.11 + vertexId * 0.01)), 0);

  vec3 aspect = vec3(resolution.y / resolution.x, 1, 1);

  mat4 mat = ident();
  mat *= scale(aspect);
  gl_Position = vec4((mat * vec4(pos, 1)).xyz, 1);
  gl_Position.z = -m1p1(v);
 // gl_Position.x += m1p1(lineId / 10.) * 0.4 + (snd1 * snd0) * 0.1;
  gl_PointSize = 2.;

  float hue = mix(0.85, 0.95, pow(snd0, 5.));
  float sat = 0.2 + pow(snd0 + 0.2, 10.);
  float val = 1.;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 0.2);
  v_color = vec4(v_color.rgb * v_color.a, 0.1);
}