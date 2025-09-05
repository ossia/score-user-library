/*{
  "DESCRIPTION": "vertex+time based highlight - Edits!",
  "CREDIT": "aaron (ported from https://www.vertexshaderart.com/art/f6Qou7QNuj5onaJeQ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 5000,
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
    "ORIGINAL_VIEWS": 3,
    "ORIGINAL_DATE": {
      "$date": 1487716907755
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 500.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

void main() {
  float quadId = floor(vertexId / 6.);
  float quadVert = mod(vertexId, 6.);
  float trisize = 2.;
  vec2 aspect = vec2(1, resolution.x / resolution.y);

  vec4 camera_scale = vec4(1. / resolution.xy /2., 1., 1.); // converts 1 unit to 1 pixel
  //vec4 camera_scale = vec4(1, 1, 1, 1);
  vec4 camera_translation = vec4(0, resolution.y, 0, 0);

  float realId = quadVert - floor(quadVert / 3.);
  float rad = PI / 2. * realId + PI / 4.;
  vec2 pos = vec2(cos(rad), sin(rad));
  pos *= vec2(trisize * 20., trisize);
  pos.y += quadId * sqrt(trisize * trisize * 2.);
  gl_Position = (vec4(pos, 0, 1) - camera_translation) * camera_scale;

  vec4 color = vec4(0.33, 0.25, 0.5, 1);
  vec4 highlight_max = vec4(1, 1, 1, 1);
  vec4 highlight_min = vec4(0, 0, 0, 0);
  float time_speed = 500.; // arbitrary
  v_color = color + mix(highlight_min, highlight_max, mod(pos.y - time * 500., resolution.y) / resolution.y) * 0.75;
}