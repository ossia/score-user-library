/*{
  "DESCRIPTION": "mousething - work in progress",
  "CREDIT": "sean (ported from https://www.vertexshaderart.com/art/khesbmKPst2TQsnnL)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 1677,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1497994989497
    }
  }
}*/

#define PI radians(180.)

void main() {
  vec2 foci[4];
  foci[0] = vec2(0,0);
  foci[1] = vec2(.2, sin(time));
  foci[2] = vec2(sin(time*.3), sin(time*.3));
  foci[3] = mouse;

  vec2 holes[3];
  holes[0] = vec2(0.5, 0.5);
  holes[1] = vec2(-0.7, .2);
  holes[2] = mouse;

  float down = floor(sqrt(vertexCount));
  float across = floor(vertexCount / down);

  float x = mod(vertexId, across);
  float y = floor(vertexId / across);

  float u = x / (across - 1.);
  float v = y / (across - 1.);

  float ux = u * 2. - 1.;
  float vy = v * 2. - 1.;

  vec2 pos = vec2(ux, vy);

  for (int i = 0; i < 3; i++)
  {
    vec2 dir = foci[i] - pos;
    float dist = length(dir);
  vec2 u_dir = dir / dist;
  vec2 offset = -0.05 * u_dir;
    pos += offset;

    dir = holes[i] - pos;
    dist = length(dir);
  u_dir = dir / dist;
  offset = 0.1 * u_dir;

    pos += offset;
  }

  gl_Position = vec4(pos, 0, 1);

  gl_PointSize = 10.0;
  gl_PointSize *= 20. / across;
  gl_PointSize *= resolution.x / 600.;

  v_color = vec4(.5,.5,0,1);

}

