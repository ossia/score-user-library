/*{
  "DESCRIPTION": "Parametric Plotter - Torus - Parametric graphing.",
  "CREDIT": "oneshade (ported from https://www.vertexshaderart.com/art/6RMx4XYpHck6oZZ4u)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 91125,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 394,
    "ORIGINAL_DATE": {
      "$date": 1612984818788
    }
  }
}*/

#define EYE_DISTANCE 2.0
#define Z_NEAR 2.5
#define Z_FAR -2.5

#define POINT_SIZE 5.0

#define PI 3.1415
#define TAU PI * 2.0

#define RESOLUTION vec2(45.0)
#define SIZE vec2(TAU, TAU)

#define r 0.75 // Radius
#define t 0.4 // Thickness

vec3 ParametricSurface(float u, float v) {
    float cu = cos(u), su = sin(u);
    float cv = cos(v), sv = sin(v);
    return vec3(r * cv + t * cv * cu, t * su, r * sv + t * sv * cu);
}

vec3 getNormal(in vec3 v) {
    return normalize(v - vec3(normalize(v.xz) * r, 0.0).xzy);
}

void main() {
    vec3 lightDir = normalize(vec3(-1.0, 1.0, 1.0));

    float u = mod(vertexId, RESOLUTION.x);
    float v = (vertexId - u) / RESOLUTION.x;
    u = u / RESOLUTION.x * SIZE.x; v = v / RESOLUTION.y * SIZE.y;

    vec3 vertex = ParametricSurface(u, v);
    vec3 color = vec3(max(0.0, dot(getNormal(vertex), lightDir)));

    vec2 rot = vec2(time, -0.5); // mouse * PI;
    float cy = cos(rot.x), sy = sin(rot.x);
    float cp = cos(rot.y), sp = sin(rot.y);
    vertex.xz *= mat2(cy, sy, -sy, cy);
    vertex.yz *= mat2(cp, sp, -sp, cp);

    vec2 screenCoords = vertex.xy / (EYE_DISTANCE - vertex.z);
    screenCoords.x *= resolution.y / resolution.x;
    float depth = (vertex.z - Z_NEAR) / (Z_FAR - Z_NEAR);
    gl_Position = vec4(screenCoords, depth, 1.0);
    gl_PointSize = POINT_SIZE / (EYE_DISTANCE - vertex.z);
    v_color = vec4(color, 1.0);
}