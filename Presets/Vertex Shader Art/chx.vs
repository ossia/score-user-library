/*{
  "DESCRIPTION": "chx",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/7BtREZnTSkBpz7W87)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 20526,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.00392156862745098,
    0.07450980392156863,
    0.49019607843137253,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1452613100753
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

float p1m1(float v) {
  return v * .5 + .5;
}

float inv(float v) {
  return 1. - v;
}

void main() {
  float id = vertexId;
  float v = id + time;
  float outV = fract(time * 10. + vertexId * 0.01);
  vec3 pos = normalize(vec3(
    m1p1(hash(v * 0.012)),
    m1p1(hash(v * 0.127)),
    m1p1(hash(v * 0.213))));
  vec3 aspect = vec3(1, resolution.x / resolution.y, 1) * 0.4;
  if (id >= 18000.) {
    pos = normalize(vec3(m1p1(hash(vertexId)), m1p1(hash(vertexId * 0.123)), 0));
    pos *= mix(1., 1.1, outV);
  }

  mat4 mat = ident();
  mat *= scale(aspect);
  // mat *= rotZ(lineV * PI * 2. + t * 1000.1);
  // mat *= rotY(lineV * PI * 1. + t * 1000.1);
  gl_Position = vec4((mat * vec4(pos, 1)).xyz, 1);
  // gl_Position.x += m1p1(lineId / 10.) * 0.4 + (snd1 * snd0) * 0.1;
  gl_PointSize = (resolution.x / 1600.) * mix(0., 20., abs(cos(p1m1(pos.z) * PI)));

  if (id < 18000.) {
    float edge = inv(abs(dot(pos, vec3(0,0,1))));
    float hue = mix(0.95, 1.1, edge);
    float sat = 1.;
    float val = p1m1(dot(pos, normalize(vec3(-0.3, 0.6, -1))));
    v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1)
      + 0.4 * pow(val, 51.)
      + vec4(1,1,1,1) * pow(edge, 15.);
    v_color.a *= mix(1.0, 2., mod(time * 60., 2.));
  } else {
    v_color = vec4(1,1,1,inv(outV));
    gl_PointSize = inv(outV) * 4.;
// v_color.a *= mix(1.0, 1., mod(time * 60., 2.));
  }
  v_color = vec4(v_color.rgb * v_color.a, v_color.a);
}