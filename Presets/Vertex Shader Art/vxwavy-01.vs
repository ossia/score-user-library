/*{
  "DESCRIPTION": "vxwavy-01 - My first vertex shader!",
  "CREDIT": "teraspora (ported from https://www.vertexshaderart.com/art/JtvN2gq9PiiSdwvHG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 1024,
  "PRIMITIVE_MODE": "LINE_LOOP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 347,
    "ORIGINAL_DATE": {
      "$date": 1536682649240
    }
  }
}*/

// My first vertexshaderart code
// John Lynch, 11-09-2018

const float TWO_PI = 6.28318530716;
float scaleFactor = 0.5;

vec2 rotate(vec2 v, float phi) {
  return vec2(v.x * cos(phi) - v.y * sin(phi),
        v.x * sin(phi) + v.y * cos(phi));
}

bool isOdd(float n) {
  return mod(n, 2.) > 0.5;
}

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

