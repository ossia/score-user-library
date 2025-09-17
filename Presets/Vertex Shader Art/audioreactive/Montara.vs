/*{
  "DESCRIPTION": "Montara",
  "CREDIT": "chriscamplin (ported from https://www.vertexshaderart.com/art/eLAMSS8iwH7ip3sS6)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 61555,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Background", "NAME": "background", "TYPE": "color", "DEFAULT": [ 0.25, 0.59, 0.9, 1.0 ] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 61,
    "ORIGINAL_DATE": {
      "$date": 1619965535529
    }
  }
}*/

#define NUM_SEGMENTS 28.0
#define NUM_POINTS (NUM_SEGMENTS * 4.0)
#define PI 3.14159265359
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat2 rotate2D(float _a) {
 return mat2(cos(_a), sin(_a), -sin(_a), cos(_a));
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
  float numLinesDown = floor(vertexCount / NUM_POINTS);
  // produces 0,1, 1,2, 2,3, ...
  float point = floor(mod(vertexId, NUM_POINTS) / 2.0) + mod(vertexId, 2.0);
  // line count
  float count = floor(vertexId / NUM_POINTS);

  float u = point / NUM_SEGMENTS; // 0 <-> 1 across line
  float v = count / numLinesDown; // 0 <-> 1 by line
  float invV = 1.0 - v;
  float s = sin(time * 0.25/2.0)/2.0 +0.25;
  // Only use the left most 1/4th of the sound texture
  // because there's no action on the right
  float historyX = u * 0.25;
  // Match each line to a specific row in the sound texture
  float historyV = (v * numLinesDown + 0.5) / IMG_SIZE(sound).y;
  float snd = texture(sound, vec2(historyX, historyV)).r;
  float x = u * fract(time / PI * 0.25) - 1.0 * snd;
  float y = v * fract(time / PI * 0.25) - 1.0 * snd * s;
  float xOff = sin(PI * count + x * 0.35) * 2.0;
  float yOff = cos(PI * count + y * 0.005) * 6.0;
  vec2 xy = vec2(
      x * mix(yOff, s * snd, invV),
      y + mod(snd * 2.0, 5.0 * xOff) * 1.0) / (v + xOff);
  gl_PointSize = snd * 20. - xOff - yOff;
  gl_PointSize *= 20.0 / numLinesDown *snd;
  gl_PointSize *= resolution.x / 30. * xOff;
  xy -= vec2(0.5);
  xy *= rotate2D(snd * PI * 2.0);
  xy += vec2(0.5);
  //xy.normalize();
  gl_Position = vec4(xy, xOff , yOff);
  xy -= vec2(0.5);
  //xy *= rotate2D(-snd * -PI * -2.0);
  xy += vec2(0.5);
  float hue = snd;
  float sat = invV;
  float val = invV;
  vec4 color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
  //color *= rotY(PI * snd * 2.);
  v_color = mix(color, background, v * v);
}