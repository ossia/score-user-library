/*{
  "DESCRIPTION": "flowerpower",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/w5qTDiEqtC8Tri6tv)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 37863,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0.1568627450980392,
    0.9372549019607843,
    0.34901960784313724,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 142,
    "ORIGINAL_DATE": {
      "$date": 1448286056390
    }
  }
}*/

// ,---. ,---. .-''-. .-------. ,---------. .-''-. _____ __ .-'''-. .---. .---. ____ ______ .-''-. .-------. ____ .-------. ,---------.
// | / | | .'_ _ \ | _ _ \\ \ .'_ _ \ \ _\ / / / _ \| | |_ _| .' __ `. | _ `''. .'_ _ \ | _ _ \ .' __ `. | _ _ \\ \
// | | | .'/ ( ` ) '| ( ' ) | `--. ,---'/ ( ` ) ' .-./ ). / ' (`' )/`--'| | ( ' ) / ' \ \| _ | ) _ \ / ( ` ) '| ( ' ) | / ' \ \| ( ' ) | `--. ,---'
// | | _ | |. (_ o _) ||(_ o _) / | \ . (_ o _) | \ '_ .') .' (_ o _). | '-(_{;}_)|___| / ||( ''_' ) |. (_ o _) ||(_ o _) / |___| / ||(_ o _) / | \
// | _( )_ || (_,_)___|| (_,_).' __ :_ _: | (_,_)___|(_ (_) _) ' (_,_). '. | (_,_) _.-` || . (_) `. || (_,_)___|| (_,_).' __ _.-` || (_,_).' __ :_ _:
// \ (_ o._) /' \ .---.| |\ \ | | (_I_) ' \ .---. / \ \ .---. \ :| _ _--. | .' _ ||(_ ._) '' \ .---.| |\ \ | |.' _ || |\ \ | | (_I_)
// \ (_,_) / \ `-' /| | \ `' /(_(=)_) \ `-' / `-'`-' \\ `-' ||( ' ) | | | _( )_ || (_.\.' / \ `-' /| | \ `' /| _( )_ || | \ `' /(_(=)_)
// \ / \ / | | \ / (_I_) \ / / / \ \\ / (_{;}_)| | \ (_ o _) /| .' \ / | | \ / \ (_ o _) /| | \ / (_I_)
// `---` `'-..-' ''-' `'-' '---' `'-..-' '--' '----'`-...-' '(_,_) '---' '.(_,_).' '-----'` `'-..-' ''-' `'-' '.(_,_).' ''-' `'-' '---'

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

#define NUM_EDGE_POINTS_PER_PETAL 19.
#define NUM_POINTS_PER_PETAL ((NUM_EDGE_POINTS_PER_PETAL - 1.) * 3.)
void getPetalPoint(const float flowerId, const float id, out vec3 pos, out float center) {
  float outId = id - floor(id / 3.) * 2. - 1.; // 0 1 2 3 4 5 6 7 8 .. 0 1 2, 1 2 3, 2 3 4
  center = step(0.5, mod(id, 3.));
  float u = outId / (NUM_EDGE_POINTS_PER_PETAL - 1.);
  float a = u * PI * 2.;
  float s = sin(a);
  float c = cos(a);
  float x = s * 0.3;
  float y = c - 1.;
  float z = u;
  pos = vec3(x, y, z) * center + vec3(0, mix(-2.0, 1.0, hash(flowerId * 0.33)) * inv(center), 0);

}

#define NUM_PETALS_PER_FLOWER 16.
#define NUM_POINTS_PER_FLOWER (NUM_POINTS_PER_PETAL * NUM_PETALS_PER_FLOWER)
void getFlowerPoint(const float flowerId, const float id, out vec3 pos, out float center) {
  float petalId = floor(id / NUM_POINTS_PER_PETAL);
  float pointId = mod(id, NUM_POINTS_PER_PETAL);
  vec3 petalPos;
  getPetalPoint(flowerId, pointId, petalPos, center);
  mat4 mat = rotZ(petalId / NUM_PETALS_PER_FLOWER * PI * 2.);
  pos = (mat * vec4(petalPos, 1)).xyz;
}

void main() {
  vec3 aspect = vec3(resolution.y / resolution.x, 1, 0.0001);
  float id = vertexId;
  float numFlowers = floor(vertexCount / NUM_POINTS_PER_FLOWER);
  float flowerId = floor(vertexId / NUM_POINTS_PER_FLOWER);// + floor(time * 100.);
  float sOff = 0.0;
  float sSpread = 0.01;
  const int numSamples = 5;
  float snd = 0.;
  for (int i = 0; i < numSamples; ++i) {
    vec2 uv = vec2(flowerId / numFlowers * 0.25, sOff + sSpread * float(i));
    snd += texture(sound, uv).r * float(numSamples - i);
  }
  snd /= float(numSamples * (numSamples + 1)) / 2.5;
  vec3 offset = vec3(m1p1(hash(flowerId)) / aspect.x, m1p1(hash(flowerId * 1.37)), -m1p1(flowerId / 10.));
  vec3 pos;
  float center;
  getFlowerPoint(flowerId, id, pos, center);
  mat4 mat = ident();
  mat *= scale(aspect);
  mat *= trans(offset);
  mat *= rotZ(time * mix(-1., 1., hash(flowerId * 1.54)));
  mat *= uniformScale(mix(0.1, 0.2, hash(flowerId)) + pow(snd, 5.0) * 0.1);
  gl_Position = vec4((mat * vec4(pos, 1)).xyz, 1);

  float hue = mix(-0.2, 0.2, fract(time * 0.1 + flowerId * 0.13 + center * 0.1));
  float sat = mix(.4, .7, hash(flowerId * 0.7));
  float val = mix(mix(0.5, 1.0, hash(flowerId * 0.27)), 0.0, center * inv(hash(flowerId * 0.73)));
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 0.0 + pow(snd + 0.3, 5.0));
  v_color = vec4(v_color.xyz * v_color.a, v_color.a);
}