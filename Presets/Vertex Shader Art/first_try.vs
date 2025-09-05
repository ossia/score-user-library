/*{
  "DESCRIPTION": "first_try",
  "CREDIT": "mrsynackster (ported from https://www.vertexshaderart.com/art/ZyWp3YSber6wbuY8a)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 26237,
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
      "$date": 1693870502946
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

void main() {
 float down = floor(sqrt(vertexCount));
 float accross = floor(vertexCount / down);

 float x=mod(vertexId,accross);
 float y=floor(vertexId/accross);
 float u = x /(accross-1.);
 float v = y / (accross-1.);

 float xoff = sin(time + y*0.2)*.1;
 float yoff = sin(time + x*0.3)*.2;

 float ux = u * 2. - 1. + xoff;
 float vy = v * 2. - 1. + yoff;

 vec2 xy = vec2(ux,vy) *0.8;

 gl_Position = vec4(xy,0,1);

 float soff = sin(time + x * y * .1) * 5.;

 gl_PointSize = 10. + soff;

 gl_PointSize *= 20. / accross;

 gl_PointSize *= resolution.x / 600.;

 v_color = vec4(0.0,1.0,0.0,1.0);

}