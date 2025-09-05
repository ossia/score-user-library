/*{
  "DESCRIPTION": "etch a sketch",
  "CREDIT": "chriscamplin (ported from https://www.vertexshaderart.com/art/HoKSKN5bu2omsjRi7)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 70,
    "ORIGINAL_DATE": {
      "$date": 1676892691716
    }
  }
}*/


struct point {
  vec3 position;
  float a;
  float b;
  float rad;
  float snd;
};

void main() {
  float snd = pow(texture(sound, vec2(0.005, 0.0025)).r, 4.);

  float v=vertexId/30.0;
  int num=int(mouse.x*10.0+10.0*snd);
  int den=int(exp(mouse.y*3.0+3.0)*snd);
  float frac=1.0-float(num)/float(den);
  vec2 xy=vec2(sin(v),cos(v)*sin(v*frac))/2.0;

  for(int i = 0; i < 1; i++) {
    xy*=abs(xy)/dot(xy, xy)-vec2(snd);
    xy*=abs(xy)/dot(xy, xy)-vec2(frac);
  }
  vec2 aspect = vec2(1, resolution.x / resolution.y);
  gl_Position = vec4(xy * aspect, -xy.x, 1);
  v_color = vec4(0,0,0, 1);
}