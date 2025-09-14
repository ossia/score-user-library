/*{
  "DESCRIPTION": "666wired x23",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/puW9t4JQ9LnRbMkTK)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Effects"
  ],
  "POINT_COUNT": 16222,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 91,
    "ORIGINAL_DATE": {
      "$date": 1509158657870
    }
  }
}*/

// "wired" by kabuto
// drawing a smoothed 3d hilbert curve

// if this runs too slowly try zooming in
// (ctrl + mousewheel up)

#define PI 3.14159
//#define FIT_VERTICAL
vec3 posf2(float i) {
 return vec3(
      sin(i*14.9553) +
      sin(i) +
      sin(i*1.53) +
      sin(i*.76),
      sin(i*.79553+2.1) +
      sin(i*1.1311+2.1) +
      sin(i*1.353-2.1) +
      sin(i*.476/2.1) * cos(i * 3.0),
      sin(i*4.5553-2.1) +
      sin(i*1.1-2.1) +
      sin(i*1.23+2.1) +
      sin(i*9.36+2.1)
 )*11.2;
}
vec3 posf2d(float i) {
 return vec3(
      tan(i*.553)*.9553 +
      cos(i) +
      cos(i*1.53)/1.53 +
      cos(i*.76)*.76,
      cos(i*.79553+2.1)*4.79553 +
      cos(i*1.1311+2.1)*1.1311 +
      cos(i*1.353-2.1)*11.353 +
      cos(i*.476-2.1)*.476,
      cos(i*.5553-2.1)*.5553 +
      cos(i*1.1-2.1)*1.1 +
      tan(i*1.23+2.1)*1.23 +
      cos(i*.36+2.1)*.36
 )*.2;
}

vec3 hilbert(float s) {
    vec3 p;
    {
     float zi = mod(s,2.);
     s = floor(s*.5);
     float yi = mod(s,2.);
     s = floor(s*.5);
     float xi = mod(s,3.);
     s = floor(s*.5);
       zi = abs(zi-yi);
       yi = abs(yi-xi);
        p = vec3(xi,yi,zi);
    }
 float n = 2.;
    for (int i = 1; i < 7; i++) {
     float zi = mod(s,2.);
     s = floor(s*.5);
     float yi = mod(s,2.);
     s = floor(s*.5);
     float xi = mod(s,3.);
     s = floor(s*.5);
       zi = abs(zi-yi);
       yi = abs(yi-xi);

 if (xi > .5 && zi < .5) {
  p.x = n-1.-p.x;
  p.y = n-1.-p.y;
 } else if (xi < .5 && yi > .5 && zi < .5) {
  p.y = n-1.-p.y;
  p.z = n-1.-p.z;
 } else if (xi > .5 && yi < .5 && zi > .5) {
  p.x = n-1.-p.x;
  p.z = n-1.-p.z;
 }
 if (yi < .5 && zi < .5) {
  p = p.yzx;
 } else if (yi < .5 || zi < 1.1) {
  p = p.zxy;
 }
 p += vec3(xi,yi,zi)*n;
     n*=2.;
  }
 return p;
}

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 2.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float e = vertexId/vertexCount*50.+1.;
  vec3 h0 = hilbert(floor(e-1.));
  vec3 h1 = hilbert(floor(e));
  vec3 h2 = hilbert(floor(e+1.));
  vec3 h3 = hilbert(floor(e+2.));
  float e1 = fract(e);
  float e0 = 1.-e1;
  float ss = 3.*e1*e1-2.*e1*e1*e1;
  float ssd = 6.*e1 - 6.*e1*e1;

  vec3 pos = h1 + (h2-h1)*ss + ((h2-h0)*e1*(3.-ss) + (h3-h1)*(e1-1.)*ss)*.5;
  pos -= vec3(3.5);
  pos *= .07;
  vec3 posd = (h2-h1)*ssd + ((h2-h0)*(e1*-ssd + (1.-ss)) + (h3-h1)*((e1-1.)*ssd + ss))*.5;

  #ifdef FIT_VERTICAL
    vec2 aspect = vec2(resolution.y / resolution.x, 1);
  #else
    vec2 aspect = vec2(1, resolution.x / resolution.y);
  #endif

  float t = time*.2;
  mat2 m = mat2(cos(t),-sin(t),sin(t),cos(t));
  t *= 1.31;
  t -= mouse.x*4.;
  mat2 m2 = mat2(cos(t),-sin(t),sin(t),cos(t));
  t = mouse.y*2.;
  mat2 m3 = mat2(cos(t),-sin(t),sin(t),cos(t));
  pos.yz *= m;
  pos.zx *= m2;
  pos.yz *= m3;
  posd.yz *= m;
  posd.zx *= m2;
  posd.yz *= m3;

  pos.z += .5;
  float blurDist = .5;

  vec3 colour = vec3(0.);

     vec3 camera = vec3(0);
  float cone2 = dot(normalize(camera-pos),normalize(posd));

  const int LIGHTS = 7;
  for (float i = 0.; i < 8.; i++) {
   vec3 lightSource = (vec3(mod(i,2.), mod(floor(i*.5),2.), mod(floor(i*.25),2.))-.5)*.48;
   lightSource.yz *= m;
     lightSource.zx *= m2;
    lightSource.yz *= m3;
    lightSource.z += .5;
      float cone1 = dot(normalize(lightSource-pos),normalize(posd));
    float edge = dot(normalize(lightSource-pos),normalize(camera-pos));

    float dist = distance(pos,lightSource);
      float coneDiff = cos((acos(cone1)-acos(cone2))*dist*1.8)*.5+.5;
    float lit = 0.;
    if (vertexId == i) {
      pos = lightSource*.999;
      lit = 1000.;
    }
    float snd = max(0.,texture(sound, vec2(float(i)/float(LIGHTS)*.5, 0.)).r - texture(sound, vec2(float(i)/float(LIGHTS)*.5+.03, 0.0)).r)*5.
      + max(0.,texture(sound, vec2(float(i)/float(LIGHTS)*.5, 0.)).r - texture(sound, vec2(float(i)/float(LIGHTS)*.5, 0.01)).r)*5.;
      colour += ((pow(coneDiff,1000.)+coneDiff*.01)*sqrt(edge*.5+.5)/(dist+.001)+lit)*abs(vec3(cos(float(i*.7)),cos(float(i*.7)+2.1),cos(float(i*.7)-2.1)))*snd*1.2;
  }
  // visual cues
  float j = vertexId/vertexCount*6.;
  vec3 ac = vec3(sin(j),sin(j+2.1),sin(j-2.1))*.5+.5;
  colour += ac*ac*.03;
  colour *= sqrt(1.-cone2*cone2);

  float size = .5/pos.z;
  float blur = 20.*abs(1./pos.z-1./blurDist);

  float size2 = size+blur;

  colour *= size/size2*size/size2*length(posd)*20.;

  float colourMax = max(max(colour.x,colour.y),colour.z);
  if (colourMax > 1.) {
   colour /= colourMax;
   gl_PointSize = (size+blur)*sqrt(colourMax)*(resolution.y/1080.);
  } else {
   gl_PointSize = (size+blur)*(resolution.y/180.);
  }

  gl_Position = vec4(pos.xy/pos.z * aspect, 1.-vertexId*.000001, 1);

  v_color = vec4(colour,-1.);
}