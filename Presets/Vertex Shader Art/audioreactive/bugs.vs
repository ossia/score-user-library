/*{
  "DESCRIPTION": "bugs",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/Ch3PxmZwN22dkrGCg)",
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
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 165,
    "ORIGINAL_DATE": {
      "$date": 1501683161683
    }
  }
}*/

#define NUM_SEGMENTS 128.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#define SEGMENTS_PER_LINE 10.
#define VERTICES_PER_LINE (SEGMENTS_PER_LINE * 2.)

float goop(float t) {
  return sin(t) + sin(t * 0.27) + sin(t * 0.13) + sin(t * 0.73);
}

float t2m1(float v) {
  return v * 2. - 1.;
}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

void main() {
  float vId = mod(vertexId, VERTICES_PER_LINE);
  float vv = vId / (VERTICES_PER_LINE - 1.);
  float lineId = floor(vertexId / VERTICES_PER_LINE);
  float numLines = floor(vertexCount / VERTICES_PER_LINE);
  float lineV = lineId / (numLines - 1.);
  float p = float(vId / 2.) + mod(vId, 2.);
  float pv = p / SEGMENTS_PER_LINE;

  float t = time * 8.;
  float vxOff = lineV * 50.;
  float vyOff = lineV * 50.;
  float vs = pv * 2.;
  vec2 xy = vec2(goop(t + vs + vxOff), goop(t + 10.5 + vs + vyOff)) * .0125;

  vec2 off = vec2(t2m1(hash(lineId * 0.123)), t2m1(hash(lineId * 0.717)));

  float su = hash(lineId * 0.511);
  float sv = abs(atan(off.x, off.y));
  float s = texture(sound, vec2(mix(0.2, 0.5, su), sv * .1)).r;

  float aspect = resolution.x / resolution.y;
  gl_Position = vec4(xy + off, -pv, 1) * vec4(1, aspect, 1, 1);
  gl_PointSize = 5. * pv;

  float hue = .5 + lineV * .1 + pv * -.1;
  float sat = .5;
  float val = 1.;

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), pv * pow(mix(0., 2., s), 4.));
  float pp = step(s, 0.5);
  v_color.rgb = mix(v_color.rgb, vec3(0,0,0), pp);
  gl_PointSize *= mix(0.5, 1., pp);
  v_color.rgb *= v_color.a;
}