/*{
  "DESCRIPTION": "zheballv4",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/dMRx2bNxuYsRKSHKt)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Effects"
  ],
  "POINT_COUNT": 20001,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 19,
    "ORIGINAL_DATE": {
      "$date": 1585678782422
    }
  }
}*/

#define NUM_POINTS 20000.0
#define PI 3.14159265
#define TWO_PI (PI * 2.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat4 persp(float fov, float aspect, float zNear, float zFar) {
  float f = tan(PI * 0.5 - 0.5 * fov);
  float rangeInv = 1.0 / (zNear - zFar);

  return mat4(
    f / aspect, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (zNear + zFar) * rangeInv, -1,
    0, 0, zNear * zFar * rangeInv * 2., 0);
}

mat4 rotY(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 1);
}

float getSound(float f, float delay) {
  // Good values for f:
  // 0.0 in bass is always around 1
  // 0.5 is in the mids, goes with music
  // 1.0 is in the highs always 0
  return texture(sound, vec2(f * 0.25, delay / IMG_SIZE(sound).y)).r;
}

vec3 curvePos(float t) {
  float phi = TWO_PI * t * 13.0;
  float theta = TWO_PI * t * 17.0;
  float r0 = 0.5;
  float r1 = 0.4;

  phi += cos(theta * 3.0) * 0.3;
  theta += sin(phi * 5.0) * 0.3;
  r0 += cos(phi) * 0.03;
  r1 += sin(theta * 3.0 + phi) * 0.05;

  phi += sin(theta * 3.0) * r0 * 1.0;
  theta += cos(phi * 2.0) * r1 * 1.0;
  r0 += sin(theta * 5.0 + phi * 1.0) * 0.03;
  r1 += cos(phi * 2.0) * 0.07;
  r0 += -cos(theta) * 0.1 * (1.0 + 0.3 * cos(phi * 13.0));

  phi += cos(theta * 3.0) * 0.2;
  theta += sin(phi * 7.0) * 0.3;
  r1 = r1 * (1.0 + 0.3 * sin(t * TWO_PI * 19.0) * (1.0 + 0.3 * cos(theta)));

  float x0 = cos(phi);
  float y0 = sin(phi);

  float x1 = cos(theta);
  float y1 = sin(theta);

  float x = x0 * (r0 + x1 * r1);
  float y = y0 * (r0 + x1 * r1);
  float z = y1 * r1;

  float rr = 1.0 / sqrt(x * x + y * y + z * z);
  float rt = sin(t * TWO_PI * 19.0);
  float f = 0.7 + 0.3 * (rr + rt * 0.2);
  x *= f;
  y *= f;
  z *= f;

  return vec3(x, y, z);
}

void main() {
  float t = vertexId / NUM_POINTS;
  vec3 p = curvePos(t);
  float r = (sqrt(p.x * p.x + p.y * p.y + p.z * p.z) - 0.5) / 0.5;

  float power = 0.0;
  for (int i = 0; i < 20; i++) power += 0.05 * pow(getSound(float(i) * 0.02 + 0.1, 0.0), 2.0);
  power = sqrt(power);

  float mix1 = getSound(r, 0.0) - r;
  float mix2 = power - r + 0.3;
  float mixt = mix1 * 3.0 + mix2 * 10.0;

  float rwave = sin(mixt * 0.8);
  float tpulse = sin((time * 0.05 + t * 100.0) * TWO_PI + mixt * 0.05);
  float trpulse = sin(r * 0.75 * TWO_PI - time);
  float trpulse_mixt = sin(r * 0.5 + mixt * 0.5);

  float rpulse = pow(0.5 + 0.5 * trpulse, 25.0);
  float rpulse_mixt = pow(0.5 + 0.5 * trpulse_mixt, 5.0);
  float pulse = pow(0.5 + 0.5 * tpulse, 150.0);

  float v = pulse * 0.5 + 0.5 * rpulse_mixt + 0.1;
  float h = sin(time * 0.2 + sin(t * TWO_PI) * 0.1);
  float s = 1.0 - ((1.0 - rpulse) * pulse);

  vec4 vertPos = rotY(time*0.1) * vec4(p, 1.0) + vec4(0.0, 0.0, -3.0, 0.0);
  gl_Position = persp(PI*0.25, resolution.x/resolution.y, 0.1, 100.0) * vertPos;
  v_color = vec4(hsv2rgb(vec3(h, s, v)), v);
}