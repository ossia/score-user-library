/*{
  "DESCRIPTION": "24-cell",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/rsfLpHMoLXeSK4ybu)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 128,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 72,
    "ORIGINAL_DATE": {
      "$date": 1576479508321
    }
  }
}*/

#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)

void main() {
  float start = mod(vertexId, 2.0);
  float x = -1.0 + 2.0 * mod(floor(vertexId / 2.0), 2.0);
  float y = -1.0 + 2.0 * mod(floor(vertexId / 4.0), 2.0);
  float z = -1.0 + 2.0 * mod(floor(vertexId / 8.0), 2.0);
  float w = -1.0 + 2.0 * mod(floor(vertexId / 16.0), 2.0);
  float idx = mod(floor(vertexId / 32.0), 4.0);
  x += (idx == .0 && start == 1.0 && x < 0.) ? 2. : 0.;
  y += (idx == 1.0 && start == 1.0 && y < 0.) ? 2. : 0.;
  z += (idx == 2.0 && start == 1.0 && z < 0.) ? 2. : 0.;
  w += (idx == 3.0 && start == 1.0 && w < 0.) ? 2. : 0.;
  vec4 xyzw = vec4(x, y, z, w);
  float a = cos(0.08*time);
  float k = sin(0.08*time);
  float b = k * mouse.x;
  float c = k * mouse.y;
  float d = k * sqrt(1. - dot(mouse, mouse));
  mat4 rot = mat4(a, -b, -c, -d,
        b, a, -d, c,
        c, d, a, -b,
        d, -c, b, a);
  xyzw = rot * xyzw;
  vec2 aspect = vec2(1, resolution.x / resolution.y);
  gl_Position = vec4(.3 * aspect * xyzw.xy, 0., 1.);
  v_color = .25 * (3. + xyzw.z) * vec4(.5, .5 * (1.+xyzw.w), .5, 0.5);
}