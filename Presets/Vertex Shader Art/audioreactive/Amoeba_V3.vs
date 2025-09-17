/*{
  "DESCRIPTION": "Amoeba V3 - Amoeba V3",
  "CREDIT": "james2 (ported from https://www.vertexshaderart.com/art/6RY7TFeo6Q9wmHb5f)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 50000,
  "PRIMITIVE_MODE": "LINE_LOOP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.01568627450980392,
    0.01568627450980392,
    0.10588235294117647,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] }, { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1677797985977
    }
  }
}*/

//KDrawmode=GL_LINE_LOOP
//KVerticesNumber=20000

#define turning 1.4//KParameter0 1.4>>100.
#define rotateXcos 1.//KParameter1 1.>>5.
#define rotateYcos 1.//KParameter2 1.>>5.
#define rotateZcos 1.//KParameter3 1.>>5.
#define spikeFactor 4. //KParameter4 1.>>10.
#define spikeFactor2 4. //KParameter5 1.>>100.

#define PI radians(180.)

float soundValues[50];
const int windowSize = 50;
float movingAverage(float value) {
  // Add the new value to the soundValues array
  for (int i = windowSize - 1; i > 0; i--) {
    soundValues[i] = soundValues[i-1];
  }
  soundValues[0] = value;

  // Calculate the moving average
  float sum = 0.0;
  float peak = 0.0;
  for (int i = 0; i < windowSize; i++) {
    sum += soundValues[i];
    if (soundValues[i]>peak)
    {
      peak = soundValues[i];
    }
  }
  float average = sum / float(windowSize);

  return average;
}

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

struct point {
  vec3 position;
  float a;
  float b;
  float rad;
  float snd;
};

point getPoint(float i, float soundValue) {

  float pointsPerTurn = floor(sqrt(vertexCount) * 2.);
  pointsPerTurn -= mod(pointsPerTurn, 16.);
  pointsPerTurn++;
  float turns = vertexCount / pointsPerTurn;

  float a = (PI + PI / turns) * i; //(acos(1.0 - 2.0 * i) / PI);
  float b = 2. * PI * i * turns;

  a -= mod(vertexId, 2.) * PI / (turns - 1.);
  a = clamp(a, 0., PI);

  float spike = pow(cos(a * spikeFactor), 4.);
  bool middle = a > PI / 8. && a < PI * 7. / 8.;
  if (middle) {
   spike *= pow(sin(b * spikeFactor2), 4.);
  }

  float snd = pow(soundValue, 4.);

  float rad = 0.35;
  rad += spike * 0.350;
  rad += snd * 0.2;

  float x = sin(a);
  float y = cos(a);
  float z = sin(b) * x;
  x *= cos(b);

  return point(vec3(x, y, z) * rad, a, b, rad, snd);
}

void main() {

  //float smoothSound = movingAverage();
   float soundValue = texture(sound, vec2(0.005, 0.025)).r * 0.8;

   point p1 = getPoint(vertexId / vertexCount,soundValue);
// point p2 = getPoint((vertexId - 1.) / vertexCount);
// point p3 = getPoint((vertexId - 2.) / vertexCount);
// vec3 normal = normalize(cross(p2.position - p1.position, p3.position - p1.position));

  float mx = sin(time - p1.rad) * turning;
// float mx = PI * -mouse.y;
  float my = time - p1.rad;
// float my = PI * -mouse.x;
  float mz = sin(time * 0.44 - p1.rad);
  mat2 rotateX = mat2(cos(mx)*rotateXcos, -sin(mx), sin(mx), cos(mx));
  mat2 rotateY = mat2(cos(my)*rotateYcos, -sin(my), sin(my), cos(my));
  mat2 rotateZ = mat2(cos(mz)*rotateZcos, -sin(mz), sin(mz), cos(mz));

  float soundAmp = 0.1;

  p1.position.yz *= rotateX * (soundValue * soundAmp);
  p1.position.xz *= rotateY * (soundValue * soundAmp);
  p1.position.xy *= rotateZ * (soundValue * soundAmp);

  float screenZ = -0.;
  float eyeZ = -4.5;
  float perspective = (eyeZ - screenZ) / (p1.position.z - eyeZ);
  p1.position.xy *= perspective;

  float aspect = resolution.x / resolution.y;
  p1.position.x /= aspect;

  gl_Position = vec4(p1.position, 1);

  gl_PointSize = 2. - p1.position.z * 5.;

  float h = fract(p1.b / (2. * PI));
  float s = (p1.rad - 0.5 * movingAverage(p1.snd)) * 3.;

  if (p1.a < PI / 8.) {
   s = mix(s, 0., 1. - p1.a / (PI / 8.));
  } else if (p1.a > PI * 7. / 8.) {
   s = mix(s, 0., 1. - (PI - p1.a) / (PI / 8.));
  }
  float v = 0.4 - p1.position.z * 2.;
// float v = normal.z * 0.5 + 0.5;

  v_color = vec4(hsv2rgb(vec3(h, s, v)), 1);
}
