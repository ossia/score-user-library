/*{
  "DESCRIPTION": "Music Stars",
  "CREDIT": "nathan2 (ported from https://www.vertexshaderart.com/art/DaM7frg7uQNDe7mK2)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Nature"
  ],
  "POINT_COUNT": 39751,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.047058823529411764,
    0.08235294117647059,
    0.09019607843137255,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 6,
    "ORIGINAL_DATE": {
      "$date": 1574462952423
    }
  }
}*/

#define PI radians(180.0)

/** Returns a random value between [0, 1) */
float rand(float val) {
 return fract(sin(val)*10000.0);
}

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 getSquarePoint(float id) {
  float x = mod(id, 2.0) + floor(id / 6.0);
  float y = mod(floor(id / 2.0) + floor(id / 3.0), 2.0);

  return vec2(x, y);
}

vec2 getCirclePoint(float id, float numSegments) {
  // Each square is made of 2 triangles, 6 points
  vec2 uv = getSquarePoint(id);

  // Calculate angle and radial values
  float angle = uv.x / numSegments * 2.0 * PI;
  float c = cos(angle);
  float s = sin(angle);

  // Translate back to x y
  float radius = uv.y;
  float x = c * radius;
  float y = s * radius;

  return vec2(x, y);
}

void main() {
  // Segments to form a circle
  float numSegments = 8.0;

  // How many points in a circle
  float numPointsPerCircle = numSegments * 6.0;

  // How many circles
  float numCircles = floor(vertexCount / numPointsPerCircle) - 1.0;

  // Which circle
  float circleId = floor(vertexId / numPointsPerCircle);

  float sizeScaler = rand(rand(circleId));

  // Sound intensity
  float snd = texture(sound, vec2(mix(0.0, 0.5, sizeScaler), 0.0)).r;

  // Size of circle
  float size = mix(0.001, 0.01, snd); // mix(0.001, 0.005, sizeScaler);

  float aspect = resolution.x / resolution.y;

  // Now get our vertex point in its circle
  vec2 xy = getCirclePoint(vertexId, numSegments) * size;
  xy = vec2(xy.x / aspect, xy.y);

  // We'll use slowed down time
  float scaledTime = time * 0.1;

  float xMotion = sin(scaledTime + PI*rand(rand(circleId*32.0)*rand(circleId)))*0.1;
  float yMotion = cos(scaledTime + PI*rand(rand(circleId*52.02)*rand(circleId - 53.0)))*0.1;
  float xOff = rand(circleId) * 2.0 - 1.0 + xMotion;
  float yOff = rand(circleId + 4.0) * 2.0 - 1.0 + yMotion;

  gl_Position = vec4(xy.x + xOff, xy.y + yOff, 0.0, 1);

  // Circle color
  float hue = 0.6;
  float sat = 0.2;
  float val = mix(0.5, 1.0, snd);
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 0.0);

}