/*{
  "DESCRIPTION": "sound tutorial 2",
  "CREDIT": "chriscamplin (ported from https://www.vertexshaderart.com/art/BM7xSvMgutERFmdBd)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1000,
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
    "ORIGINAL_VIEWS": 47,
    "ORIGINAL_DATE": {
      "$date": 1620675248251
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 4.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat4 rotX(float angle) {

    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      1, 0, 0, 0,
      0, c, s, 0,
      0,-s, c, 0,
      0, 0, 0, 1);
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

void main() {
   //
   float cols = floor(sqrt(vertexCount));
   float rows = floor(vertexCount / cols);
   // vertex ID is number of the vertex
   float x = mod(vertexId, rows); // divide by 10 keep the remainder,
   float y = floor(vertexId / rows); //. floor throws away the remainder 0000 1111 2222

   float s = sin(PI * time + y * 0.25);
   float xOff = 0.;//sin(PI * time * 1.5 + y * 0.25) * 0.1;
   float yOff = 0.; //sin(time + x * 0.25) * 0.2;
   float soff = 0.; //sin(time * x * y * 0.0005) * 0.5;

   float u = x /(rows - 1.);
   float v = y / (rows - 1.);\
        // sound

    float ux = u * 2. - 1. + xOff;
   float vy = v * 2. - 1. + yOff;

   vec2 xy = vec2(ux, vy) * 1.25;

   // concentrate on center
   float sv = abs(v - 0.5) * 2.0;
   float su = abs(u - 0.5) * 2.0;

    // circular - atan returns values between PI & -PI
   float au = abs(atan(su, sv)) / PI;
   float av = length(vec2(su, sv));
    float snd = texture(sound, vec2(au * 0.05, av * 0.25)).r;

   vec4 pos = vec4(xy, 0, 1);
   //pos *= rotX(PI * snd * 0.1);
   //pos *= rotY(PI * snd * 0.1);

 gl_Position = pos;
   gl_PointSize = snd * 45.0 + soff;
   gl_PointSize *= 20.0 / cols * 0.05 + snd;
   gl_PointSize *= resolution.x / 600.;

   float pump = step(0.8, snd);
    float hue = u * 0.1 * snd + 0.2 + time * 0.1;
    hue = smoothstep(x, y, pump);
    float sat = mix(0., 1.0, pump);
   // add more impact using pow
    float val = pow(snd + 0.1, 5.0);
    vec4 color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
    color *= rotY(PI * snd);
    //background += 0.1;
    //vec4 finalColor = mix(color, background, s);

    v_color = color;
  }