/*{
  "DESCRIPTION": "headrush fork",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/3Szoo7khkBA4exnsR)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 662,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 99,
    "ORIGINAL_DATE": {
      "$date": 1461171128296
    }
  }
}*/

/*

        ,--. ,--. ,--. ,--.
,--. ,--.,---. ,--.--.,-' '-. ,---. ,--. ,--. ,---. | ,---. ,--,--. ,-| | ,---. ,--.--. ,--,--.,--.--.,-' '-.
 \ `' /| .-. :| .--''-. .-'| .-. : \ `' / ( .-' | .-. |' ,-. |' .-. || .-. :| .--'' ,-. || .--''-. .-'
  \ / \ --.| | | | \ --. / /. \ .-' `)| | | |\ '-' |\ `-' |\ --.| | \ '-' || | | |
   `--' `----'`--' `--' `----''--' '--'`----' `--' `--' `--`--' `---' `----'`--' `--`--'`--' `--'

*/

#define PI radians(180.)

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
  return sin(t) + sin(t * 0.27) + sin(t * 0.13) + sin(t * 0.73);
}

vec3 getCenterPoint(const float id, vec2 seed) {
  float a0 = id + seed.x;
  float a1 = id + seed.y;
  return vec3(
    (sin(a0 * 0.39) + sin(a0 * 0.73) + sin(a0 * 1.27)) / 3.,
    (sin(a1 * 0.43) + sin(a1 * 0.37) + cos(a1 * 1.73)) / 3.,
    0);
}

void getQuadPoint(const float quadId, const float pointId, float thickness, vec2 seed, out vec3 pos, out vec2 uv) {
  vec3 p0 = getCenterPoint(quadId + 0.0, seed);
  vec3 p1 = getCenterPoint(quadId + 0.1, seed);
  vec3 p2 = getCenterPoint(quadId + 0.2, seed);
  vec3 p3 = getCenterPoint(quadId + 0.3, seed);
  vec3 perp0 = normalize(p2 - p0).yxz * vec3(-1, 1, 0) * thickness;
  vec3 perp1 = normalize(p3 - p1).yxz * vec3(-1, 1, 0) * thickness;

  float id = pointId;
  float ux = mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx

  pos = vec3(mix(p1, p2, vy) + mix(-1., 1., ux) * mix(perp0, perp1, vy));
  uv = vec2(ux, vy);
}

#define POINTS_PER_LINE 1800.
#define QUADS_PER_LINE (POINTS_PER_LINE / 6.)
void main() {
  float lineId = floor(vertexId / POINTS_PER_LINE);
  float quadCount = POINTS_PER_LINE / 6.;
  float pointId = mod(vertexId, 6.);
  float quadId = floor(mod(vertexId, POINTS_PER_LINE) / 6.);
  vec3 pos;
  vec2 uv;

  float snd0 = 0.5;//texture(sound, vec2(0.13 + lineId * 0.005, quadId / quadCount * 0.01)).r;
  float snd1 = 0.5;//texture(sound, vec2(0.14 + lineId * 0.005, quadId / quadCount * 0.01)).r;

  getQuadPoint(quadId * 0.02 + time * 1.1 * (lineId + 1.), pointId, pow(snd0, 7.0) * 0.5, vec2(pow(snd0, 2.), pow(snd1, 2.0)), pos, uv);

  vec3 aspect = vec3(resolution.y / resolution.x * 2., 2, 1);

  mat4 mat = ident();
  mat *= scale(aspect);
  gl_Position = vec4((mat * vec4(pos, 1)).xyz, 1);
  gl_Position.z = -m1p1(quadId / quadCount);
  gl_Position.x += m1p1(lineId / 50.) * 0.4 + (snd1 * snd0) * 0.1;
  gl_PointSize = 4.;

  float hue = mix(0.95, 1.0, fract(lineId / 5.3));
  float sat = 1.;
  float val = step(0.5, snd1);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), quadId / quadCount);
  v_color = vec4(v_color.rgb * v_color.a, v_color.a);
}