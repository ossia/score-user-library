/*{
  "DESCRIPTION": "Bezier Patch - Quadratic bezier.",
  "CREDIT": "oneshade (ported from https://www.vertexshaderart.com/art/qGALguswrydAHGpCK)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 11610,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 207,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1618968064322
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

vec3 QuadBezier1D(in vec3 a, in vec3 b, in vec3 c, in float t) {
    float tInv = 1.0 - t;
    return a * tInv * tInv + 2.0 * b * tInv * t + c * t * t;
}

vec3 QuadBezier2D(in vec3 a, in vec3 b, in vec3 c,
        in vec3 d, in vec3 e, in vec3 f,
        in vec3 g, in vec3 h, in vec3 i,
        in float u, in float v) {
    return QuadBezier1D(QuadBezier1D(a, b, c, u), QuadBezier1D(d, e, f, u), QuadBezier1D(g, h, i, u), v);
}

VertexAndNormal getPos(in float id) {
    float t1 = time * 0.5, t2 = time, t3 = time * 1.25;

    float c1 = cos(t1), s1 = sin(t1);
    float c2 = cos(t2), s2 = sin(t2);
    float c3 = cos(t3), s3 = sin(t3);

    vec3 a = vec3(c3, s2, s1) * 1.25;
    vec3 b = vec3(s3 * s2, c1, s3) * 1.25;
    vec3 c = vec3(c2, c1, s3) * 1.25;
    vec3 d = vec3(s1, c2 * c3, s2) * 1.25;
    vec3 e = vec3(c2, c3, s1) * 1.25;
    vec3 f = vec3(c3, s1, c2) * 1.25;
    vec3 g = vec3(c2, s3, c1) * 1.25;
    vec3 h = vec3(c1, s3, s2) * 1.25;
    vec3 i = vec3(s1, s2, c3) * 1.25;

    float fid = floor(id / 6.0);
    int cid = int(mod(id, 6.0));

    vec2 edgeStep = 1.0 / RESOLUTION;

    float x = mod(fid, RESOLUTION.x);
    float y = (fid - x) / RESOLUTION.x;

    float u = x / RESOLUTION.x;
    float v = y / RESOLUTION.y;

    vec3 v1 = QuadBezier2D(a, b, c, d, e, f, g, h, i, u + edgeStep.x, v);
    vec3 v2 = QuadBezier2D(a, b, c, d, e, f, g, h, i, u, v);
    vec3 v3 = QuadBezier2D(a, b, c, d, e, f, g, h, i, u, v + edgeStep.y);
    vec3 nor = normalize(cross(v2 - v1, v3 - v1));

    if (cid == 1) u += edgeStep.x;
    if (cid == 2 || cid == 3) u += edgeStep.x, v += edgeStep.y;
    if (cid == 4) v += edgeStep.y;

    vec3 pos = QuadBezier2D(a, b, c, d, e, f, g, h, i, u, v);
    return VertexAndNormal(pos, nor);
}

void main() {
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