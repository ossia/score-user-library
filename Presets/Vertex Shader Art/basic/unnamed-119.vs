/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "yonatan (ported from https://www.vertexshaderart.com/art/aFBig76hWcPDu5Kf5)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 46656,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1537741567716
    }
  }
}*/

/* https://www.dwitter.net/d/10041
c.width|=f=(u,v,a,s,i)=>{for(i=6;s>29?i--:x.fillRect(u,v,9,9);f(u+S(b=i+i/21-a)*(q=s+s*S(b*6)**99),v+C(b)*q,b*2,s/2));}
f(960,540,t/200,600)
*/

#define PI radians(180.)
#define TAU radians(360.)
// vertexCount is not a constant?
#define VCNT pow(6.0,3.0)

vec3 hsv2rgb(vec3 c) { // This one came with the default shader...
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  const int levels = 6; // 6**6 = 46656 (points)
  vec2 aspect = vec2(resolution.y / resolution.x, 1.0);
  vec2 p = vec2(0);
  float a = 0.0;
  float angle = time / 400.0, mag, idMod, i = vertexId;
  float h = 0.0;
  float scale = 1.0;
  for(int level = 0; level < levels; level++) {
    a = angle * 2.0;
    idMod = mod(i, 6.0);
    // f(u+S(b=i+i/21-a)*(q=s+s*S(b*6)**99),v+C(b)*q,b*2,s/2));}
    angle = idMod * TAU / 6.0 + float(levels - level) + a;
    mag = 1.0 + pow(abs(sin(angle * 6.0)), 99.0);
    p = p / 2.0 + vec2(sin(angle), cos(angle)) * mag;
    h = h / 6.0 + idMod;
    i = (i - idMod) / 6.0;
  }
  gl_Position = vec4(aspect * p / 2.0, 0, 1);
  v_color = vec4(hsv2rgb(vec3(mod(h, PI), .75, .5)), 1.0);
  gl_PointSize = 2.0;
}