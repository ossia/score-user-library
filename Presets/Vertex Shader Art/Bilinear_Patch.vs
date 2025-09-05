/*{
  "DESCRIPTION": "Bilinear Patch - First attempt at creating a grid of connected triangles.",
  "CREDIT": "oneshade (ported from https://www.vertexshaderart.com/art/mFr92RbhPmuJXKXWK)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 11610,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 156,
    "ORIGINAL_DATE": {
      "$date": 1616519502747
    }
  }
}*/

#define EYE_DISTANCE 2.0
#define Z_NEAR 2.5
#define Z_FAR -2.5

#define RESOLUTION vec2(45.0)

#define PI 3.1415

struct VertexAndNormal {
    vec3 pos;
    vec3 nor;
};

VertexAndNormal getPos(in float id) {
    float t1 = time * 0.5, t2 = time, t3 = time * 1.25;

    float c1 = cos(t1), s1 = sin(t1);
    float c2 = cos(t2), s2 = sin(t2);
    float c3 = cos(t3), s3 = sin(t3);

    vec3 a = vec3(c3, s2, s1) * 1.25;
    vec3 b = vec3(s3 * s2, c1, s3) * 1.25;
    vec3 c = vec3(c2, c1, s3) * 1.25;
    vec3 d = vec3(s1, c2 * c3, s2) * 1.25;

    float fid = floor(id / 6.0);
    int cid = int(mod(id, 6.0));

    vec2 edgeStep = 1.0 / RESOLUTION;

    float x = mod(fid, RESOLUTION.x);
    float y = (fid - x) / RESOLUTION.x;

    float u = x / RESOLUTION.x;
    float v = y / RESOLUTION.y;

    vec3 v1 = mix(mix(a, b, u + edgeStep.x), mix(c, d, u + edgeStep.x), v);
    vec3 v2 = mix(mix(a, b, u), mix(c, d, u), v);
    vec3 v3 = mix(mix(a, b, u), mix(c, d, u), v + edgeStep.y);
    vec3 nor = normalize(cross(v2 - v1, v3 - v1));

    if (cid == 1) u += edgeStep.x;
    if (cid == 2 || cid == 3) u += edgeStep.x, v += edgeStep.y;
    if (cid == 4) v += edgeStep.y;

    vec3 pos = mix(mix(a, b, u), mix(c, d, u), v);
    return VertexAndNormal(pos, nor);
}

void main() {
    //vec3 light = normalize(vec3(-1.0, 1.0, 1.0));

    //vec2 mouseRot = mouse * PI;
    //float cy = cos(mouseRot.x), sy = sin(mouseRot.x);
    //float cp = cos(mouseRot.y), sp = sin(mouseRot.y);

    VertexAndNormal vertex = getPos(vertexId);
    //vertex.pos.xz *= mat2(cy, sy, -sy, cy);
    //vertex.pos.yz *= mat2(cp, sp, -sp, cp);

    vec2 screenCoords = vertex.pos.xy / (EYE_DISTANCE - vertex.pos.z);
    screenCoords.x *= resolution.y / resolution.x;
    float depth = (vertex.pos.z - Z_NEAR) / (Z_FAR - Z_NEAR);
    gl_Position = vec4(screenCoords, depth, 1.0);
    v_color = vec4(abs(vertex.nor), 1.0);
}