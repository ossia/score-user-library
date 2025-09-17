/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "w.e._aa (ported from https://www.vertexshaderart.com/art/Hg6xE7LkftDQPNqAW)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 256,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.6470588235294118,
    0.6470588235294118,
    0.6470588235294118,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 36,
    "ORIGINAL_DATE": {
      "$date": 1449457728267
    }
  }
}*/

/*

        _ _ _ _
        ( ) ( ) ( ) ( )
 _ _ ___ __ | | ___ __ __ __ | |_ ___ _| | ___ __ ___ __ | |
( V )( o_)( _)( _)( o_)\ V /(_' ( _ )( o )/ o )( o_)( _)( o )( _)( _)
 \_/ \( /_\ /_\ \( /_^_\/__)/_\||/_^_\\___\ \( /_\ /_^_\/_\ /_\

*/

#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0
#define NUM_LINES_DOWN 64.0
#define PI radians(180.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
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

void main() {
  float v = floor(vertexId / 2.0) / vertexCount * 2.;
  float u = sin(time * 0.001 + time * (vertexId + 1.) * 0.1) * 1.;

  // Only use the left most 1/4th of the sound texture
  // because there's no action on the right
  float historyX = hash(u) * 0.25 + 0.1;
  // Match each line to a specific row in the sound texture
  float historyV = v * 0.004;
  float snd1 = texture(sound, vec2(historyX, historyV)).r;
  float snd2 = texture(sound, vec2(historyX + 0.1, historyV)).r;
  float snd3 = texture(sound, vec2(0.1, v)).r;
  vec2 off = vec2(
    cos(snd1 * PI * 8.),
    sin(snd2 * PI * 6.4));

  vec2 xy = vec2(
      m1p1(hash(time + vertexId)),
      m1p1(hash(time + vertexId + 1.)));
// snd1 * 2. - 1.,
// snd2 * 2. - 1.);// * mix(1., -1., mod((time + vertexId * 0.1 + snd1) * 60., 2.));
  gl_Position = vec4(xy * 0.1 + off, 0, 1);

  float hue = u;
  float sat = 0.;
  float val = 0.;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
  v_color = mix(v_color, vec4(1,0,0,1), step(0.78, snd3));
  gl_PointSize = 4.;
}