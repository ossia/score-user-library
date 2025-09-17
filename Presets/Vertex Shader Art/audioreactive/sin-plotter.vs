/*{
  "DESCRIPTION": "sin-plotter",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/6EhsqQMiTAN8xv9yr)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 14400,
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
    "ORIGINAL_VIEWS": 76,
    "ORIGINAL_DATE": {
      "$date": 1490180943383
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

#define PI radians(180.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
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

float m1p1(float v) {
  return v * 2. - 1.;
}

vec3 getCenterPoint(const float id, vec2 seed, float time) {
  float a0 = id + seed.x;
  float a1 = id + seed.y;
  return vec3(
    cos(0.01* id * time) * (sin(a0 * 0.39) + sin(a0 * 0.73) + sin(a0 * 1.27)) / 3.,
    sin(0.01*id * time) * (sin(a1 * 0.43) + sin(a1 * 0.37) + cos(a1 * 1.73)) / 3.,
    0);
}

void getQuadPoint(const float quadId, const float pointId, float thickness, vec2 seed, out vec3 pos, out vec2 uv) {
  vec3 p0 = getCenterPoint(quadId + 0.0, seed, time);
  vec3 p1 = getCenterPoint(quadId + 0.1, seed, time);
  vec3 p2 = getCenterPoint(quadId + 0.2, seed, time);
  vec3 p3 = getCenterPoint(quadId + 0.3, seed, time);
  vec3 perp0 = normalize(p2 - p0).yxz * vec3(-1, 1, 0) * thickness;
  vec3 perp1 = normalize(p3 - p1).yxz * vec3(-1, 1, 0) * thickness;

  float id = pointId;
  float ux = mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx

  pos = vec3(mix(p1, p2, vy) + mix(-1., 1., ux) * mix(perp0, perp1, vy));
  uv = vec2(0,0);//vec2(ux, vy);
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

  float snd0 = 0.4; //0.5*sin(time); //texture(sound, vec2(0.13 + lineId * 0.05, quadId / quadCount * 0.01)).r;
  float snd1 = 0.0;//*cos(lineId*0.1); //texture(sound, vec2(0.14 + lineId * 0.05, quadId / quadCount * 0.01)).r;

  getQuadPoint(quadId * 0.02 + time * (lineId + 1.),
        pointId,
        0.01,
        vec2(0, 0),
        pos,
        uv);

  vec3 aspect = vec3(resolution.y / resolution.x, 1, 1);

  mat4 mat = ident();
  mat *= scale(aspect);
  gl_Position = vec4((mat * vec4(pos, 1)).xyz, 1);
  gl_Position.z = -m1p1(quadId / quadCount);
  gl_Position.x += m1p1(lineId / 10.) * 0.4 + (snd1 * snd0) * 0.1;
  gl_PointSize = 4.;

  float hue = mix(0.95, 1.5, lineId * 0.1);
  float sat = 1.;
  float val = 1.;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), quadId / quadCount);
  v_color = vec4(v_color.rgb * v_color.a, v_color.a);
}