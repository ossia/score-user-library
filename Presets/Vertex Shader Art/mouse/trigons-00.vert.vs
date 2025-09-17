/*{
  "DESCRIPTION": "trigons-00.vert - learning...",
  "CREDIT": "teraspora (ported from https://www.vertexshaderart.com/art/NkGu9MkBw25Y4yT2Y)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 26501,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1536795392021
    }
  }
}*/

// My second vertexshaderart code attempt
// John Lynch, 11-09-2018
#define PI 3.141592653589793234
#define TWO_PI 6.28318530716

// ==================================================================
// Some functions adapted from Github -
// https://github.com/tobspr/GLSL-Color-Spaces/blob/master/ColorSpaces.inc.glsl
// - not tested rigorously by me, seem to work!

vec3 hue2rgb(float hue)
{
    float R = abs(hue * 6. - 3.) - 1.;
    float G = 2. - abs(hue * 6. - 2.);
    float B = 2. - abs(hue * 6. - 4.);
    return clamp(vec3(R,G,B), 0., 1.);
}

// Converts from HSL to linear RGB
vec3 hsl2rgb(vec3 hsl) {
    vec3 rgb = hue2rgb(hsl.x);
    float C = (1. - abs(2. * hsl.z - 1.)) * hsl.y;
    return (rgb - 0.5) * C + hsl.z;
}

// ======================== USEFUL FUNCTIONS ========================

float scaleFactor = 1.0;

vec2 rotate(vec2 v, float phi) {
  return vec2(v.x * cos(phi) - v.y * sin(phi),
        v.x * sin(phi) + v.y * cos(phi));
}

bool isOdd(float n) {
  return mod(n, 2.) > 0.5;
}

// ==== == ==== == ==== == ==== == ==== == ==== == ==== == ==== == ==

vec2 circle(float vid, float numSegments) {

  float ux = floor(vid / 6.) + mod(vid, 2.);
  float vy = mod(floor(vid / 2.) + floor(vid / 3.), 2.);

  float phi = ux / numSegments * TWO_PI;
  float r = (vy + 2.) * 0.1;
  float c = cos(phi);
  float s = sin(phi);

  float x = c * r;
  float y = s * r;

  return vec2(x, y);
}

void main() {
  float segs = mod(time, 20.);
  vec2 circleXY = circle(vertexId, segs);
  float numPointsPerCircle = segs * 6.;

  float circleId = floor(vertexId / numPointsPerCircle);
  float circleCount = floor(vertexCount / numPointsPerCircle);

  float ySpan = floor(sqrt(circleCount));
  float xSpan = floor(circleCount / ySpan);

  float x = mod(circleId, xSpan);
  float y = floor(circleId / xSpan);

  float u = x / (xSpan - 1.);
  float v = y / (xSpan - 1.);

  float ux = u * 2. - 1. + mouse.x;
  float vy = v * 2. - 1. + mouse.y;

  vec2 xy = circleXY * 0.1 + vec2(ux, vy) * scaleFactor * (sin(time / 2.) + 0.5);
  xy *= length(xy);
  xy = rotate(xy, -time * PI / 10.) + 0.1 * sin(time);
  float su = abs(u - 0.5) * 2.;
  float sv = abs(v - 0.5) * 2.;

  // float au = abs(atan(su, sv)) / PI;
  // float av = length(vec2(su, sv));

  gl_Position = vec4(xy, 0.99, 1) ;
  gl_PointSize = 1.;

  vec3 col = hue2rgb(cos(time / 6.));
  v_color = vec4(col, 1.);

  // vec3 col = vec3(cos(circleId * sin(time / 6.)) , 0., 1. - cos(time));
  // v_color = vec4(col, 1.);

}

/*
void main() {
  float span = floor(sqrt(vertexCount));

  float u = mod(vertexId, span) / (span - 1.);
  float v = floor(vertexId / span) / (span - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  float yDelta = (8. * sin(time / 4. * ux + vy ) + sin(time / 2.) + sin(time) + 3. * sin(time / 2.)) / 20.;
  float xDelta = yDelta * 1.8;
  if (isOdd(vertexId)) {
    yDelta = -yDelta + 2. * mouse.y ;
  }
  vec2 xy = vec2(ux + xDelta, vy + yDelta * (ux / resolution.x) * vertexId) * scaleFactor;
  xy = rotate(xy, sin(time / 20.) * TWO_PI * mouse.x / 4.);
  gl_Position = vec4(xy, 0, 1);
  gl_PointSize = 10.;
  gl_PointSize += 1. / span;
  gl_PointSize *= 0.1 * resolution.x * resolution.y / 262144.;
  float k = vertexId / vertexCount;
  v_color = vec4(k * 0.8, 0.2, 0.6 - k * mod(time, 10.) / 2., 1.);
}
*/