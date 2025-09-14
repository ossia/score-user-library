/*{
  "DESCRIPTION": "Shadertoy Renderer - Point based shadertoy renderer.",
  "CREDIT": "oneshade (ported from https://www.vertexshaderart.com/art/9ikkGGKbk6D4k8eRa)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 99225,
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
    "ORIGINAL_VIEWS": 215,
    "ORIGINAL_DATE": {
      "$date": 1612921919282
    }
  }
}*/

#define iResolution vec2(315.0)
#define iMouse mouse
#define iTime time

#define renderSize vec2(1.0)

/***************************************************************************/

float sdBox(in vec3 p, in vec3 d) {
    vec3 q = abs(p) - d;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdBox2D(in vec2 p, in vec2 d) {
    vec2 q = abs(p) - d;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0);
}

vec2 pModPolar(in vec2 p, in float offs, in float reps) {
    float rep = 6.28 / reps, hRep = 0.5 * rep;
    return sin(mod(atan(p.y, p.x) + offs + hRep, rep) - hRep + vec2(1.57, 0.0)) * length(p);
}

float mapScene(in vec3 p) {
    float turn = iTime;

    float c = cos(turn), s = sin(turn);
    vec3 p1 = p, p2 = p;

    float cell = mod(floor(atan(p1.z, p1.x) / 6.28 * 6.0 + 0.5), 2.0);
    float dir = cell * 2.0 - 1.0, lock = cell * 0.157;
    p1.xz = pModPolar(p1.xz, 0.0, 6.0) - vec2(3.0, 0.0);
    p1.xy *= mat2(c, -s, s, c);

    float teeth1 = sdBox(vec3(pModPolar(p1.xz, turn * dir + lock, 20.0), p1.y).xzy - vec3(1.35, 0.0, 0.0), vec3(0.25, 0.175, 0.075));
    float ring1 = sdBox2D(vec2(length(p1.xz) - 1.1, p1.y), vec2(0.25));
    float gears1 = min(ring1, teeth1);

    cell = mod(floor(atan(p2.z, p2.x) / 6.28 * 6.0), 2.0);
    dir = cell * 2.0 - 1.0, lock = cell * 0.157;
    p2.xz = pModPolar(p2.xz, 0.52, 6.0) - vec2(2.75, 0.0);
    p2.xy *= mat2(c, -s, s, c);
    p2.xy = p2.yx;

    float teeth2 = sdBox(vec3(pModPolar(p2.xz, turn * dir + lock, 20.0), p2.y).xzy - vec3(1.35, 0.0, 0.0), vec3(0.25, 0.175, 0.075));
    float ring2 = sdBox2D(vec2(length(p2.xz) - 1.1, p2.y), vec2(0.25));
    float gears2 = min(ring2, teeth2);

    return min(gears1, gears2) - 0.025;
}

vec3 getNormal(in vec3 p) {
    vec3 e = vec3(0.01, 0.0, 0.0);
    return normalize(vec3(mapScene(p + e.xyy) - mapScene(p - e.xyy),
        mapScene(p + e.yxy) - mapScene(p - e.yxy),
        mapScene(p + e.yyx) - mapScene(p - e.yyx)));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 screenCenter = 0.5 * iResolution.xy;

    vec2 mouse = (iMouse.xy - screenCenter) / iResolution.y * 3.14;
    vec2 uv = (fragCoord.xy - screenCenter) / iResolution.y;
    fragColor = vec4(0.0, 0.0, 0.0, 1.0);

    vec3 ro = vec3(0.0, 0.0, 10.0);
    vec3 rd = normalize(vec3(uv, -1.0));

    vec2 rot = vec2(iTime, -0.6);

    float cy = cos(rot.x), sy = sin(rot.x);
    float cp = cos(rot.y), sp = sin(rot.y);

    ro.yz *= mat2(cp, -sp, sp, cp);
    rd.yz *= mat2(cp, -sp, sp, cp);

    ro.xz *= mat2(cy, -sy, sy, cy);
    rd.xz *= mat2(cy, -sy, sy, cy);

    float t = 0.0;
    for (float i=0.0; i < 100.0; i++) {
        vec3 p = ro + rd * t;
        float d = mapScene(p);
        if (d < 0.001) {
        vec3 n = getNormal(p);
        vec3 l = vec3(-0.58, 0.58, 0.58);

        l.yz *= mat2(cp, -sp, sp, cp);
        l.xz *= mat2(cy, -sy, sy, cy);

        fragColor.rgb += max(0.0, dot(n, l));
        break;
        }

        if (t > 50.0) {
        fragColor.rgb = mix(vec3(0.25, 0.25, 1.0), vec3(1.0), 0.5 + 0.5 * rd.y);
        break;
        }

        t += d;
    }
}

/***************************************************************************/

void main() {
    float x = mod(vertexId, iResolution.x);
    float y = (vertexId - x) / iResolution.y;
    vec2 point = vec2(x, y) / iResolution * renderSize - 0.5 * renderSize;
    gl_Position = vec4(point, 0.0, 1.0);
    gl_Position.x *= resolution.y / resolution.x;
    gl_PointSize = 1.0;
    mainImage(v_color, vec2(x, y));
}