/*{
  "DESCRIPTION": "rotate motion tutorial",
  "CREDIT": "chriscamplin (ported from https://www.vertexshaderart.com/art/WzeZofWAP8mZ2aNBz)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 69,
    "ORIGINAL_DATE": {
      "$date": 1620055602473
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
   float rows = floor(sqrt(vertexCount));
   float cols = floor(vertexCount / rows);
   // vertex ID is number of the vertex
   float x = mod(vertexId, rows); // divide by 10 keep the remainder,
   float y = floor(vertexId / rows); //. floor throws away the remainder 0000 1111 2222

   float s = sin(PI * time + y * 0.25);
   float xOff = sin(PI * time * 1.5 + y * 0.25) * 0.1;
   float yOff = cos(time + x * 0.25) * 0.1;
   float soff = cos(time * 1.4 + x * y * 0.0005) * 0.5;

   float u = x /(rows - 1.);
   float v = y / (rows - 1.);
   float ux = u * 2. - 1. + xOff;
   float vy = v * 2. - 1. + yOff;
    vec4 pos = vec4(ux, vy, s, 1);
   pos*=rotY(PI*time*.125);
   pos*=rotX(PI*time*.125);
 gl_Position = pos;
   gl_PointSize = 3.0 + soff;
   //gl_PointSize *= 20.0 / cols;
   //gl_PointSize *= resolution.x / 600.;
    float hue = s;
    hue = smoothstep(x, y, xOff);
    float sat = v * xOff;
    float val = u;
    vec4 color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
    color *= rotY(PI * soff);
    //background += 0.1;
    vec4 finalColor = mix(color, background, s);

    v_color = finalColor;
  }