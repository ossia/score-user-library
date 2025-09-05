/*{
  "DESCRIPTION": "red ring",
  "CREDIT": "macro (ported from https://www.vertexshaderart.com/art/tYmHG6XpcftYrE9DD)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 3072,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1600427232722
    }
  }
}*/


// vsa

//asdf

#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float m1p1(float v) {
  return v * 2. - 1.;
}

void main() {
  float v = vertexId;
  float vertex = mod(v, 6.);
  v = (v-vertex)/6.;
  float a1 = mod(v, 32.);
  v = (v-a1)/32.;
  float a2 = v-8.;

  float a1n = (a1+.5)/32.*2.*PI;
  float a2n = (a2+.5)/32.*2.*PI;

  a1 += mod(vertex,2.);
  a2 += vertex==2.||vertex>=4.?1.:0.;

  a1 = a1/32.*2.*PI;
  a2 = a2/32.*2.*PI;

  float snd = texture(sound, vec2(abs(m1p1(a2n / 2. / PI)) * 0.2 + 0.05, a2 / 2. / PI * 0.25)).r;

  vec3 pos = vec3(cos(a1)*cos(a2),sin(a2),sin(a1)*cos(a2)) * mix(0.4, 3.2, pow(snd, 6.));
  vec3 norm = vec3(cos(a1n)*cos(a2n),sin(a2n),sin(a1n)*cos(a2n));
  norm = vec3(cos(a1)*cos(a2),sin(a2),sin(a1)*cos(a2));

  pos.xz *= mat2(cos(time),sin(time),-sin(time),cos(time));
  pos.yz *= mat2(cos(time),sin(time),-sin(time),cos(time));
  norm.xz *= mat2(cos(time),sin(time),-sin(time),cos(time));
  norm.yz *= mat2(cos(time),sin(time),-sin(time),cos(time));

  vec3 light = vec3(0);

  float t = time * 0.05;
  light = pow(dot(normalize(vec3( .3, .4,-.5)),norm)*.5+.5,5.)*hsv2rgb(vec3(.8 + t,.0*1.3,1.))
     + pow(dot(normalize(vec3( .1,-.2,-.5)),norm)*.5+.5,5.)*hsv2rgb(vec3(.3 + t,.0*1.5,1.))
     + pow(dot(normalize(vec3(-.5,-.1,-.5)),norm)*.5+.5,5.)*hsv2rgb(vec3(.3 + t,.0*1.7,1.))
     + pow(dot(normalize(vec3( .7,-.2,-.5)),norm)*.5+.5,5.)*hsv2rgb(vec3(.8 + t,.0*1.4,1.));

  light *= mix(0.5, 2.0, snd);
  //light *= mix(vec3(1,0,0), vec3(0,0,1), vertexId / 32./ 32. / 3.);
  light *= mix(vec3(1), vec3(1,0,0), step(0.66, snd));

  gl_Position = vec4(pos.x*resolution.y/resolution.x,pos.y, pos.z*.5+.5, 1);

  v_color = vec4(vec3(light), 1);
}//axcx