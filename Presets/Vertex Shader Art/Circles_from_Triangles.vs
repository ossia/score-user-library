/*{
  "DESCRIPTION": "Circles from Triangles",
  "CREDIT": "chaerinpark (ported from https://www.vertexshaderart.com/art/4QEXMdBaekmPQnFf6)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 47846,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1685511783828
    }
  }
}*/

//Name : Chaerin Park
//Assignment : Exercise - Vertexshaderart : Circles from Triangles
//Course : CS250
//Spring 2023

vec3 hsv2rgb(vec3 c)
{
 c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
   vec4 k = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
   vec3 p = abs(fract(c.xxx + k.xyz) * 6.0 - k.www);
   return c.z * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y);
}

#define PI radians(180.0)

mat4 rotZ(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

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

vec2 getCirclePoint(float id, float numCircleSegments)
{
  float ux = floor(id / 6.0) + mod(id, 2.0);
  float vy = mod(floor(id / 2.0) + floor(id / 3.0), 2.0);

  float angle = ux / 20.0 * PI * 2.0;
  float c = cos(angle);
  float s = sin(angle);

  float radius = vy + 1.0;

  float x = c * radius;
  float y = s * radius;

  return vec2(x,y);
}

void main()
{
   float numCircleSegments = 12.0;
   vec2 circleXY = getCirclePoint(vertexId, numCircleSegments);

   float numPointsPerCircle = numCircleSegments * 6.0;
   float circleId = floor(vertexId / numPointsPerCircle);
   float numCircles = floor(vertexCount / numPointsPerCircle);

   float sliceId = floor(vertexId / 6.0);
   float oddSlice = mod(sliceId, 2.0);

 float down = floor(sqrt(numCircles));
   float across = floor(numCircles / down);

   float x = mod(circleId, across);
   float y = floor(circleId / across);

   float u = x / (across - 1.0);
   float v = y / (across - 1.0);

   float xoff = 0.0; //sin(time + y * 0.2) * 0.1;
   float yoff = 0.0; //sin(time * 1.1 + x * 0.3) * 0.2;

   float ux = u * 2.0 - 1.0 + xoff;
   float vy = v * 2.0 - 1.0 + yoff;

   float su = abs(u - 0.5) * 2.0;
   float sv = abs(v - 0.5) * 2.0;
   float au = abs(atan(su, sv)) / PI;
   float av = length(vec2(su, sv));
   float snd = texture(sound, vec2(au * 0.05, av * 0.25)).r;

   float aspect = resolution.x / resolution.y;
   float sc = pow(snd + 0.2, 5.0) * mix(1.0, -0.5, oddSlice);

   sc *= 20.0 / across;

   vec4 pos = vec4(circleXY, 0.0, 1.0);
   mat4 mat = ident();
   mat *= scale(vec3(1.0, aspect, 1.0));
   mat *= rotZ(time * 0.1);
   mat *= trans(vec3(ux, vy, 0.0) * 1.3);
  mat *= rotZ(snd * 20.0 * sign(ux));
   mat *= uniformScale(0.05 * sc);

   //vec2 xy = circleXY * 0.1 * sc + vec2(ux, vy) * 1.3;

   gl_Position = mat * pos;

   float soff = 0.0; //sin(time + x * y * 0.02) * 5.0;

   gl_PointSize = pow(snd + 0.2, 5.0) * 30.0 + soff;
   gl_PointSize *= 20.0 / across;
   gl_PointSize *= resolution.x / 600.0;

   float pump = step(0.8, snd);
   float hue = u * 0.1 + snd * 0.2 + time * 0.1; //sin(time + v * 20.0) * 0.05;
   float sat = mix(0.5, 1.0, pump);
   float val = mix(0.1, pow(snd + 0.2, 5.0), pump);

   hue = hue + pump * oddSlice * 0.5 + pump * 0.33;
   val += oddSlice * pump;

   v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}