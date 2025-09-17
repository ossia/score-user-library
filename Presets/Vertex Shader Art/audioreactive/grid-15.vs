/*{
  "DESCRIPTION": "grid",
  "CREDIT": "robsouthgate4 (ported from https://www.vertexshaderart.com/art/yvHEThAy6Yvf5mRjp)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 3925,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1526172269922
    }
  }
}*/



vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 vec2Random(vec2 st) {
  st = vec2(dot(st, vec2(0.040,-0.250)),
  dot(st, vec2(269.5,183.3)));
  return -1.0 + 2.0 * fract(sin(st) * 43758.633);
}

float gradientNoise(vec2 st) {
  vec2 i = floor(st);
  vec2 f = fract(st);

  vec2 u = smoothstep(0.0, 1.0, f);

  return mix(mix(dot(vec2Random(i + vec2(0.0,0.0)), f - vec2(0.0,0.0)),
        dot(vec2Random(i + vec2(1.0,0.0)), f - vec2(1.0,0.0)), u.x),
        mix(dot(vec2Random(i + vec2(0.0,1.0)), f - vec2(0.0,1.0)),
        dot(vec2Random(i + vec2(1.0,1.0)), f - vec2(1.0,1.0)), u.x), u.y);
}

float ran(float x) {
  return gradientNoise(vec2(x, 1.0));
}

void main() {
   float down = floor(sqrt(vertexCount));
    float across = floor(vertexCount / down);

   vec2 snd = texture(sound, vec2(1.0)).xy;

   float x = mod(vertexId, across);
    float y = floor(vertexId / across);

   float u = x / (across -1.);
    float v = y / (across - 1.);

    float xoff = ran(time + y * 0.9);
    float yoff = fract(time + x * 0.3);

   float ux = u * 2. - 1. + xoff;
    float vy = v * 2. - 1. + yoff;

    vec2 xy = vec2(ux, vy) * 0.9;

 gl_Position = vec4(xy * 1., 0, 1);
    gl_PointSize = 10.;
   gl_PointSize *= 20. / down;
   gl_PointSize *= resolution.x / 600.;
   v_color = vec4(1,vy,0,1);
}