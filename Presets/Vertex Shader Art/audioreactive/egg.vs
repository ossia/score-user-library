/*{
  "DESCRIPTION": "egg",
  "CREDIT": "archer (ported from https://www.vertexshaderart.com/art/TCDXMAgg5629wT79d)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
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
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 11,
    "ORIGINAL_DATE": {
      "$date": 1550085587591
    }
  }
}*/

#define PI radians(180.)
#define MAX_RAY_STEPS 30
#define MIN_DISTANCE 0.0001

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 distanceEstimator(vec3 p) {
  //float sx = mod(floor(p.y / 2.0) / 320.0, 1.0);
  //float sy = mod(floor(p.z / 2.0) / 160.0, 1.0);
  //float snd = texture(sound, vec2(sx, sy)).r;

  vec3 sphereCenter = vec3(4.0, 0.0, 0.0);
  float radius = 1.0;

  vec3 pNew = vec3(p.x, mod(abs(p.y), 2.0) - 1.0, mod(abs(p.z), 2.0) - 1.0);

  float distance = length(pNew - sphereCenter) - radius;

  int eggi = int(p.z / (radius * 2.0)) * 2;
  int eggj = int(p.y / (radius * 2.0)) * 2;

  return vec2(abs(distance), float(eggi + eggj) / 40.0 + time / 10.0);
}

vec3 trace(vec3 from, vec3 direction) {
 float totalDistance = 0.0;
 int steps;
    vec2 result;
 for (int i=0; i < MAX_RAY_STEPS; i++) {
        steps++;
  vec3 p = from + totalDistance * direction;
        result = distanceEstimator(p);
  float distance = result.x;
  totalDistance += distance;
  if (distance < MIN_DISTANCE) break;
 }
 return vec3(result.y, 1.0, 1.0-float(steps)/float(MAX_RAY_STEPS));
}

void main() {

  float wh = floor(sqrt(vertexCount));
  gl_PointSize = max(resolution.x, resolution.y) / wh;

  float sx = (mod(vertexId, wh) / wh) * 2.0 - 1.0;
  float sy = (ceil(vertexId / wh) / wh) * 2.0 - 1.0;

  gl_Position = vec4(sx, sy, 0.0, 1.0);

  float trueX = sx * resolution.x / 500.0;
  float trueY = sy * resolution.y / 500.0;

  vec3 camera = vec3(-1.0, 0.0, 0.0);
  vec3 direction = normalize(vec3(1.0, trueX, trueY));
  vec3 pixelColor = trace(camera, direction);

  v_color = vec4(hsv2rgb(pixelColor), 1.0);
}