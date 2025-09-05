/*{
  "DESCRIPTION": "Rainbow Menger",
  "CREDIT": "archer (ported from https://www.vertexshaderart.com/art/sQ6ahpp85mA5CcSNJ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 306,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1550091375088
    }
  }
}*/

#define PI radians(180.)
#define MAX_RAY_STEPS 50
#define MIN_DISTANCE 0.001
#define MENGER_LAYERS 3
#define FOV 4.0 / 3.0

vec3 hsv2rgb(vec3 c) { // Change HSV to RGB
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float distanceEstimator(vec3 pos) { // Distance estimator for Menger Sponge
    // Loop the Menger Sponge
    float x = 2.0 / 3.0 - mod(abs(pos.x) + 2.0 / 3.0, 4.0 / 3.0);
    float y = 2.0 / 3.0 - mod(abs(pos.y) + 2.0 / 3.0, 4.0 / 3.0);
    float z = 2.0 / 3.0 - mod(abs(pos.z) + 2.0 / 3.0, 4.0 / 3.0);

    // Center it by changing position and scale
 x = x * 0.5 + 0.5;
    y = y * 0.5 + 0.5;
    z = z * 0.5 + 0.5;

 float xx = abs(x - 0.5) - 0.5;
    float yy = abs(y - 0.5) - 0.5;
    float zz = abs(z - 0.5) - 0.5;

 float d1 = max(xx,max(yy,zz)); // Distance to a box
 float d = d1; // Current computed distance
 float p = 1.0;

    for (int i=1; i <= MENGER_LAYERS; i++) {
  float xa = mod(3.0 * x * p, 3.0);
  float ya = mod(3.0 * y * p, 3.0);
  float za = mod(3.0 * z * p, 3.0);
  p *= 3.0;

  xx = 0.5 - abs(xa - 1.5);
        yy = 0.5 - abs(ya - 1.5);
        zz = 0.5 - abs(za - 1.5);

        // Distance inside the 3 axis-aligned square tubes
  d1 = min(max(xx, zz), min(max(xx, yy), max(yy, zz))) / p;

       // Intersection
  d = max(d, d1);
    }

 return d * 2.0;
}

float trace(vec3 from, vec3 direction) { //
 float totalDistance = 0.0;
 int steps;
 for (int i=0; i < MAX_RAY_STEPS; i++) {
        steps++;
  vec3 p = from + totalDistance * direction;
  float distance = distanceEstimator(p);
  totalDistance += distance;
  if (distance < MIN_DISTANCE) break;
 }
 return 1.0 - float(steps) / float(MAX_RAY_STEPS);
}

void main() {

  float pixelDensity = floor(sqrt(vertexCount));
  gl_PointSize = max(resolution.x, resolution.y) / pixelDensity;

  // Convert vertices to screenspace pixels
  float sx = (mod(vertexId, pixelDensity) / pixelDensity) * 2.0 - 1.0;
  float sy = (ceil(vertexId / pixelDensity) / pixelDensity) * 2.0 - 1.0;

  gl_Position = vec4(sx, sy, 0.0, 1.0);

  // Convert screenspace pixels to worldspace pixels
  float trueX = sx * resolution.x / 500.0;
  float trueY = sy * resolution.y / 500.0;

  // Get rotation
  float rotation = -mouse.x + PI / 2.0;

  // Get camera position and direction per pixel
  vec3 camera = vec3(0.0, mod(time, FOV), 0.0);
  vec3 direction = normalize(vec3(FOV * cos(rotation) + trueX * sin(rotation), FOV * sin(rotation) + trueX * -cos(rotation), trueY));

  // Get pixel value and set vertex color
  float pixelVal = trace(camera, direction);
  vec3 pixelColor = hsv2rgb(vec3(pixelVal * 3.0, 0.3, pixelVal * 0.3 + 0.7));

  v_color = vec4(pixelColor, 1.0);
}