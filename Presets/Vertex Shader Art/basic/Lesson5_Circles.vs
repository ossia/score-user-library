/*{
  "DESCRIPTION": "Lesson5_Circles",
  "CREDIT": "plasticrainbow (ported from https://www.vertexshaderart.com/art/5btpWTSD8Kwb767eh)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 40000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0.25098039215686274,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1623851122044
    }
  }
}*/

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#define PI radians(180.0)

vec2 getCirclePoint(float id, float numCircleSegments) {
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);

  float angle = ux / numCircleSegments * PI * 2.;
  float c = cos(angle);
  float s = sin(angle);

  float radius = vy + 1.;

  float x = c * radius;
  float y = s * radius;

  return vec2(x, y);

}

void main() {
  float numCircleSegments = 20.;
  vec2 circleXY = getCirclePoint(vertexId,
        numCircleSegments);

  float numPointsPerCircle = numCircleSegments * 6.;
  float circleID = floor(vertexId / numPointsPerCircle);
  float numCircles = floor(vertexCount / numPointsPerCircle);

  float down = floor(sqrt(numCircles));
  float across = floor(numCircles / down);

  float x = mod(circleID , across);
  float y = floor(circleID / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xoff = sin(time + y * 0.2) * 0.1;
  float yoff = sin(time * 1.1 + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xoff;
  float vy = v * 2. - 1. + yoff;

  float aspect = resolution.x / resolution.y;
  vec2 xy = circleXY * 0.1 + vec2(ux, vy) * 1.5;

  gl_Position = vec4(xy, 0, 1) * vec4(1., aspect, 1., 1.);

  float soff = sin(time * 1.2 + x * y * 0.02) * 5.;

  float hue = u * .1 + sin(time * 1.3 + v * 20.) * 0.05;
  float sat = 1.;
  float val = sin(time * 1.4 + v * u * 20.) * .5 + .5;

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);

}