/*{
  "DESCRIPTION": "3D Point Cloud Scene",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/nvRC9PH5c7FhYT6vm)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Nature"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 97,
    "ORIGINAL_DATE": {
      "$date": 1626776959057
    }
  }
}*/

#define EYE_DISTANCE 2.0
#define Z_NEAR 2.5
#define Z_FAR -2.5

#define POINT_SIZE 7.0

#define PI 3.1415

#define RESOLUTION vec3(45.0)
#define SIZE vec3(2.5)

// New hash based on hash13() from "Hash without Sine" by Dave_Hoskins (https://www.shadertoy.com/view/4djSRW)
// 4 in, 1 out
float Hash41(in vec4 p) {
 p = fract(p * 0.1031);
    p += dot(p, p.zwyx + 31.32);
    return fract((p.x + p.y) * p.z - p.x * p.w);
}

float SmoothNoise4D(in vec4 p) {
    vec4 cell = floor(p);
    vec4 local = fract(p);
    local *= local * (3.0 - 2.0 * local);

    float ldbq = Hash41(cell);
    float rdbq = Hash41(cell + vec4(1.0, 0.0, 0.0, 0.0));
    float ldfq = Hash41(cell + vec4(0.0, 0.0, 1.0, 0.0));
    float rdfq = Hash41(cell + vec4(1.0, 0.0, 1.0, 0.0));
    float lubq = Hash41(cell + vec4(0.0, 1.0, 0.0, 0.0));
    float rubq = Hash41(cell + vec4(1.0, 1.0, 0.0, 0.0));
    float lufq = Hash41(cell + vec4(0.0, 1.0, 1.0, 0.0));
    float rufq = Hash41(cell + vec4(1.0, 1.0, 1.0, 0.0));
    float ldbw = Hash41(cell + vec4(0.0, 0.0, 0.0, 1.0));
    float rdbw = Hash41(cell + vec4(1.0, 0.0, 0.0, 1.0));
    float ldfw = Hash41(cell + vec4(0.0, 0.0, 1.0, 1.0));
    float rdfw = Hash41(cell + vec4(1.0, 0.0, 1.0, 1.0));
    float lubw = Hash41(cell + vec4(0.0, 1.0, 0.0, 1.0));
    float rubw = Hash41(cell + vec4(1.0, 1.0, 0.0, 1.0));
    float lufw = Hash41(cell + vec4(0.0, 1.0, 1.0, 1.0));
    float rufw = Hash41(cell + 1.0);

    return mix(mix(mix(mix(ldbq, rdbq, local.x),
        mix(lubq, rubq, local.x),
        local.y),

        mix(mix(ldfq, rdfq, local.x),
        mix(lufq, rufq, local.x),
        local.y),

        local.z),

        mix(mix(mix(ldbw, rdbw, local.x),
        mix(lubw, rubw, local.x),
        local.y),

        mix(mix(ldfw, rdfw, local.x),
        mix(lufw, rufw, local.x),
        local.y),

        local.z),

        local.w);
}

float FractalNoise4D(in vec4 p) {
    p *= 2.0;

    float nscale = .80;
    float tscale = -0.21;
    float value = -.10;

    for (int octave=0; octave < 5; octave++) {
        value += SmoothNoise4D(p) * nscale;
        tscale += nscale;
        nscale *= 0.5;
        p *= 1.0;
    }

    return value / tscale;
}

float mapShape(vec3 p) {
    return FractalNoise4D(vec4(p, time * 0.25)) - .4;
}

vec3 mapColor(in vec3 p) {
    vec3 lightDir = normalize(vec3(-1.0, 1.0, -1.40));
    vec2 e = vec2(0.001, 0.0);
    vec3 normal = normalize(vec3(mapShape(p + e.xyy) - mapShape(p - e.xyy),
        mapShape(p + e.yxy) - mapShape(p - e.yxy),
        mapShape(p + e.yyx) - mapShape(p - e.yyx)));

    return vec3(max(0.0, dot(normal, lightDir)) + 0.31);
}

void main() {
    float t = time * 0.25;

    float cellId = vertexId;
    float gridX = mod(cellId, RESOLUTION.x);
    float gridY = mod(cellId - gridX, RESOLUTION.x * RESOLUTION.y) / RESOLUTION.x;
    float gridZ = (cellId - gridX - gridY * RESOLUTION.x) / RESOLUTION.x / RESOLUTION.y;
    vec3 gridPoint = vec3(gridX, gridY, gridZ) / RESOLUTION * SIZE - 0.45 * SIZE;

    vec3 vertex = mapShape(gridPoint) < 0.0 ? gridPoint : vec3(0.0);
    vec3 color = mapColor(vertex);

    vec2 mouseRot = mouse * PI;
    float cy = cos(mouseRot.x)*sin(time-0.825)+.5, sy = sin(mouseRot.x*cos(time*0.2)*2.);
    float cp = cos(mouseRot.y)*cos(time+2.), sp = sin(mouseRot.y);
    vertex.xz *= mat2(cy, sy, -sy, cy);
    vertex.yz *= mat2(cp, sp, -sp, cp);

    vec2 screenCoords = vertex.xy / (EYE_DISTANCE - vertex.z);
    screenCoords.x *= resolution.y / resolution.x;
    float depth = (vertex.z - Z_NEAR) / (Z_FAR - Z_NEAR);
    gl_Position = vec4(screenCoords, depth, .750);
    gl_PointSize = POINT_SIZE / (EYE_DISTANCE - vertex.z);
    v_color = vec4(color, 1.0);
}