/*{
  "DESCRIPTION": "Sparks",
  "CREDIT": "8bitrick (ported from https://www.vertexshaderart.com/art/QCpubvSnQsitsMWjB)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Particles"
  ],
  "POINT_COUNT": 5000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 12,
    "ORIGINAL_DATE": {
      "$date": 1449287089778
    }
  }
}*/


#define PI 3.14159
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float m1p1(float v) { return v * 2. - 1.; }

void main()
{
  float NUM_FLOWERS = 13.;
  float verts_per_flower = vertexCount / NUM_FLOWERS;
  float flower = floor(vertexId / verts_per_flower);
  float flower_per = flower / (NUM_FLOWERS-1.);
  float hash_flower = hash(flower_per-0.17777);
  vec2 center = vec2(m1p1(hash_flower), m1p1(hash(hash_flower))) * 0.6;

  float vertex_per = mod(vertexId, verts_per_flower) / verts_per_flower;
  float freq = vertex_per * 0.8 + 0.1;
  float amp = texture(sound,vec2(freq,0.)).r;// + (flower_per) - 1. + hash(flower_per);

  float layers = 37.;
  float angle = fract(hash(vertexId/(vertexCount-1.)) * layers) * 0.333 * PI + (0.333 * PI);
  vec2 xy = center + vec2(cos(angle), sin(angle)) * amp;

  float dist = clamp(0.,1.,(center.y+1.)*(center.y+1.)-1.);

  gl_PointSize = mix(10.0, 5., dist);
  gl_Position = vec4(xy,0,1);
  v_color = mix(vec4(hsv2rgb(vec3(amp*0.21, 1.-amp, 1.)), 1.-flower_per), background, dist - 0.5);
}
