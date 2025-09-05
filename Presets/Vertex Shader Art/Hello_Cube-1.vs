/*{
  "DESCRIPTION": "Hello Cube - First shader here.",
  "CREDIT": "oneshade (ported from https://www.vertexshaderart.com/art/Y3bsPmhHZNkBkDdhQ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 600,
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
    "ORIGINAL_VIEWS": 362,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1612891074673
    }
  }
}*/

#define EYE_DIST 2.0

void main() {
    float pointId = mod(vertexId, 100.0);
    float faceId = floor(vertexId / 100.0);

    /*
    Face ID:
     Right - 0
      Left - 1
       Top - 2
    Bottom - 3
     Front - 4
      Back - 5
    */

    vec3 pos = vec3(0.0, mod(pointId, 10.0), 0.5);
    pos.x = (pointId - pos.y) / 10.0;
    pos.xy = pos.xy / 10.0 - 0.5;

    if (mod(faceId, 2.0) == 1.0) pos.z *= -1.0;
    if (faceId == 0.0 || faceId == 1.0) pos = pos.zyx;
    if (faceId == 2.0 || faceId == 3.0) pos = pos.xzy;

    // Set color before transforms so the colors don't slip
    v_color = vec4(pos * 2.0 + 1.0, 1.0);

    float c = cos(time), s = sin(time);
    pos.xz *= mat2(c, s, -s, c);
    pos.yz *= mat2(c, s, -s, c);
    pos *= 1.5;

    gl_Position = vec4(pos.xy / (EYE_DIST - pos.z), 0.0, 1.0);
    gl_Position.x *= resolution.y / resolution.x;
    gl_PointSize = 5.0 / (EYE_DIST - pos.z);
}