/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "sylistine (ported from https://www.vertexshaderart.com/art/n5oxjfMDGtJusocHH)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 10000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.49411764705882355,
    0.49411764705882355,
    0.49411764705882355,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1,
    "ORIGINAL_DATE": {
      "$date": 1501890230761
    }
  }
}*/

#define PI radians(180.)
#define TAU radians(360.)

mat4 camera(){
  float a = resolution.y / resolution.x;
  float fov = radians(110.);
  float f = tan(PI * 0.5 - fov * 0.5);
  float near = 0.1;
  float far = 1000.;
  float invrange = 1. / (near - far);

  return mat4(
    f * a, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (near + far) * invrange, -1,
    0, 0, near * far * invrange * 2., 1);
}

void main()
{
  float triId = floor(vertexId / 3.);
  float triIdx = mod(vertexId, 3.);
  float quadHalf = mod(triId, 2.);
  // 0 1 2 2 3 0 0 1 2 2 3 0
  float quadIdx = mod(triIdx + quadHalf * 2., 4.);
  float quadId = floor(vertexId / 6.);
  float s = sin(quadIdx / 4. * TAU + (PI / 4.));
  float c = cos(quadIdx / 4. * TAU + (PI / 4.));
  vec3 v_pos = vec3(s, c, 0);

  float qs_across = 25.;
  vec3 q_pos = vec3(floor(quadId / qs_across) * sqrt(2.), mod(quadId, qs_across) * sqrt(2.), 0);

  vec4 offset = vec4(-10, -10, 0, 0);

  gl_Position = camera() * vec4((q_pos + v_pos).xy, -5., 1) + offset;
  v_color = vec4(sin(v_pos.y * v_pos.x + time) * 0.5 + 0.5, v_pos.y * 0.5 + 0.5, 0, 1);
}