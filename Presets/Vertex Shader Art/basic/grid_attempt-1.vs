/*{
  "DESCRIPTION": "grid attempt",
  "CREDIT": "evilprofesseur (ported from https://www.vertexshaderart.com/art/GRmubu72jMXJivdL4)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1000,
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
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1472561364301
    }
  }
}*/

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  float down = sqrt(vertexCount);
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float xOffset = sin(time + y * 0.2) * 0.1;
  float yOffset = sin(time + x * 0.3) * 0.2;

  float ux = u * 2. - 1. + xOffset; // switch from 0-1 to -1-1
  float vy = v * 2. - 1. + yOffset;

  vec2 xy = vec2(ux, vy) *1.4;

  gl_Position = vec4(xy, 0, 1);

  float sizeOffset = sin(time + x * y * 0.02) * 5.;

  gl_PointSize = 7. + sizeOffset;
  gl_PointSize *= 20.0 / across;
  gl_PointSize *= resolution.x / 600.0;

  v_color = vec4(1,v,u,1);
}