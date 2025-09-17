/*{
  "DESCRIPTION": "alien slinky",
  "CREDIT": "jshrake (ported from https://www.vertexshaderart.com/art/Rj6BcdcHrfFGGfN27)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
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
    "ORIGINAL_VIEWS": 704,
    "ORIGINAL_LIKES": 3,
    "ORIGINAL_DATE": {
      "$date": 1544623567682
    }
  }
}*/

#define TWOPI 6.28318530718
#define PI 3.14159265359
#define DEG2RAD 0.01745329251
#define RAD2DEG 57.2957795131
#define HASHSCALE1 .1031

float hash11(float p) {
  vec3 p3 = fract(vec3(p) * HASHSCALE1);
  p3 += dot(p3, p3.yzx + 19.19);
  return fract((p3.x + p3.y) * p3.z);
}

// from http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c) {
    c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat3 rotX(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat3(1.0, 0.0, 0.0, 0.0, c, s, 0.0, -s, c);
}

mat3 rotY(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat3(c, 0.0, s, 0.0, 1.0, 0.0, -s, 0.0, c);
}

mat3 rotZ(float a) {
  float s = sin(a);
  float c = cos(a);
  return mat3(c, s, 0.0, -s, c, 0.0, 0.0, 0.0, 1.0);
}

mat4 perspective(vec3 pa, vec3 pb, vec3 pc, vec3 pe, float n, float f) {
    vec3 vr = normalize(pb - pa);
    vec3 vu = normalize(pc - pa);
    vec3 vn = cross(vr, vu);
    vec3 va = pa - pe;
    vec3 vb = pb - pe;
    vec3 vc = pc - pe;
    float d = -dot(va, vn);
    float nod = n / d;
    float l = dot(vr, va) * nod;
    float r = dot(vr, vb) * nod;
    float b = dot(vu, va) * nod;
    float t = dot(vu, vc) * nod;

    // glFrustum
    float x = 2. * n / (r - l);
    float y = 2. * n / (t - b);
    float A = (r + l) / (r - l);
    float B = (t + b) / (t - b);
    float C = -(f + n) / (f - n);
    float D = -2. * f * n / (f - n);
    mat4 P = mat4(
        x, 0, 0, 0,
        0, y, 0, 0,
        A, B, C, -1,
        0, 0, D, 0
    );
    return P;
}

mat4 camera(vec3 pa, vec3 pb, vec3 pc, vec3 pe, float n, float f) {
    vec3 vr = normalize(pb - pa);
    vec3 vu = normalize(pc - pa);
    vec3 vn = cross(vr, vu);
    mat4 cam = mat4(
        vec4(vr, 0),
        vec4(vu, 0),
        vec4(vn, 0),
        vec4(-pe, 1));
    return cam;
}

vec2 quad(float id) {
    float ux = floor(id / 6.) + mod (id, 2.);
    float vy = mod(floor(id / 2.) + floor(id / 3.), 2.);
    float x = ux;
    float y = vy;
    // generate vertices [-1, 1] x [-,1 1]
    return 2. * mod(vec2(x, y), vec2(2, 2)) - 1.;
}

void main() {
    // screen + camera setup
    float screen_width_mm = 350.90;
    float screen_height_mm = 247.1;
    float aspect = screen_width_mm / screen_height_mm;
    float head_to_screen_mm = 1000.;
    vec3 pa = 0.5 * vec3(-screen_width_mm, -screen_height_mm, 0);
    vec3 pb = 0.5 * vec3(screen_width_mm, -screen_height_mm, 0);
    vec3 pc = 0.5 * vec3(-screen_width_mm, screen_height_mm, 0);
    vec3 pe = vec3(0, 0, head_to_screen_mm);
    float n = 0.01;
    float f = 2000.;
    mat4 P = perspective(pa, pb, pc, pe, n, f);
    mat4 C = camera(pa, pb, pc, pe, n, f);

    float quad_id = floor(vertexId / 6.0);
    float quad_count = floor(vertexCount / 6.0);
    float quad_hash = hash11(quad_id + 5.0);
    float quad_pct = quad_id / quad_count;

    vec2 quad_size = vec2(1.0);
    quad_size.x *= aspect;

    float wrap = (0.5 + 0.5 * sin(0.15*time)) * 50.0;
    float r = (0.2 + 0.1*sin(50.0*quad_pct * TWOPI)) * screen_height_mm;
    float x = r * cos(wrap * quad_pct * TWOPI);
    float y = r * sin(wrap * quad_pct * TWOPI);
    float z = (quad_pct - 0.5) * 0.7 * screen_height_mm;
    vec3 worldPos =
      rotX(DEG2RAD * 45.0) *
      rotY(DEG2RAD * 33.0) *
      (vec3(quad_size * quad(vertexId), 0.0) + vec3(x,y,z));
    vec4 camPos = C * vec4(worldPos, 1.0);
    gl_Position = P *camPos;

    // write the color
    vec3 hsv = vec3(0.5 + 0.2 * quad_pct, 0.9, 1.0);
    v_color = vec4(hsv2rgb(hsv), 1.0);
}