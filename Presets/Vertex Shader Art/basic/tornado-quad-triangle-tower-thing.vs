/*{
  "DESCRIPTION": "tornado-quad-triangle-tower-thing - quick experiment",
  "CREDIT": "jshrake (ported from https://www.vertexshaderart.com/art/RRi3txAyxdQDsZW35)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 41536,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 441,
    "ORIGINAL_LIKES": 4,
    "ORIGINAL_DATE": {
      "$date": 1528672237466
    }
  }
}*/

#define ACROSS 1000
// from http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c) {
    c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#define HASHSCALE1 .1031
#define HASHSCALE3 vec3(.1031, .1030, .0973)
#define HASHSCALE4 vec4(.1031, .1030, .0973, .1099)
float hash11(float p)
{
 vec3 p3 = fract(vec3(p) * HASHSCALE1);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

//----------------------------------------------------------------------------------------
// 1 out, 2 in...
float hash12(vec2 p)
{
 vec3 p3 = fract(vec3(p.xyx) * HASHSCALE1);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

//----------------------------------------------------------------------------------------
// 1 out, 3 in...
float hash13(vec3 p3)
{
 p3 = fract(p3 * HASHSCALE1);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

//----------------------------------------------------------------------------------------
// 2 out, 1 in...
vec2 hash21(float p)
{
 vec3 p3 = fract(vec3(p) * HASHSCALE3);
 p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.xx+p3.yz)*p3.zy);

}

//----------------------------------------------------------------------------------------
/// 2 out, 2 in...
vec2 hash22(vec2 p)
{
 vec3 p3 = fract(vec3(p.xyx) * HASHSCALE3);
    p3 += dot(p3, p3.yzx+19.19);
    return fract((p3.xx+p3.yz)*p3.zy);

}

//----------------------------------------------------------------------------------------
/// 2 out, 3 in...
vec2 hash23(vec3 p3)
{
 p3 = fract(p3 * HASHSCALE3);
    p3 += dot(p3, p3.yzx+19.19);
    return fract((p3.xx+p3.yz)*p3.zy);
}

//----------------------------------------------------------------------------------------
// 3 out, 1 in...
vec3 hash31(float p)
{
   vec3 p3 = fract(vec3(p) * HASHSCALE3);
   p3 += dot(p3, p3.yzx+19.19);
   return fract((p3.xxy+p3.yzz)*p3.zyx);
}

//----------------------------------------------------------------------------------------
/// 3 out, 2 in...
vec3 hash32(vec2 p)
{
 vec3 p3 = fract(vec3(p.xyx) * HASHSCALE3);
    p3 += dot(p3, p3.yxz+19.19);
    return fract((p3.xxy+p3.yzz)*p3.zyx);
}

//----------------------------------------------------------------------------------------
/// 3 out, 3 in...
vec3 hash33(vec3 p3)
{
 p3 = fract(p3 * HASHSCALE3);
    p3 += dot(p3, p3.yxz+19.19);
    return fract((p3.xxy + p3.yxx)*p3.zyx);

}

//----------------------------------------------------------------------------------------
// 4 out, 1 in...
vec4 hash41(float p)
{
 vec4 p4 = fract(vec4(p) * HASHSCALE4);
    p4 += dot(p4, p4.wzxy+19.19);
    return fract((p4.xxyz+p4.yzzw)*p4.zywx);

}

//----------------------------------------------------------------------------------------
// 4 out, 2 in...
vec4 hash42(vec2 p)
{
 vec4 p4 = fract(vec4(p.xyxy) * HASHSCALE4);
    p4 += dot(p4, p4.wzxy+19.19);
    return fract((p4.xxyz+p4.yzzw)*p4.zywx);

}

//----------------------------------------------------------------------------------------
// 4 out, 3 in...
vec4 hash43(vec3 p)
{
 vec4 p4 = fract(vec4(p.xyzx) * HASHSCALE4);
    p4 += dot(p4, p4.wzxy+19.19);
    return fract((p4.xxyz+p4.yzzw)*p4.zywx);
}

//----------------------------------------------------------------------------------------
// 4 out, 4 in...
vec4 hash44(vec4 p4)
{
 p4 = fract(p4 * HASHSCALE4);
    p4 += dot(p4, p4.wzxy+19.19);
    return fract((p4.xxyz+p4.yzzw)*p4.zywx);
}

float thash12(vec2 p) {
 return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 thash33(vec3 p) {
 p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
     dot(p,vec3(269.5,183.3,246.1)),
     dot(p,vec3(113.5,271.9,124.6)));
 return fract(sin(p)*43758.5453123);
}

mat3 rotX( float fAngle ) {
    float s = sin( fAngle );
    float c = cos( fAngle );
    return mat3( 1.0, 0.0, 0.0,
        0.0, c, s,
        0.0, -s, c );
}

mat3 rotY( float fAngle ) {
    float s = sin( fAngle );
    float c = cos( fAngle );
    return mat3( c, 0.0, s,
        0.0, 1.0, 0.0,
        -s, 0.0, c );

}

mat3 rotZ( float fAngle ) {
    float s = sin( fAngle );
    float c = cos( fAngle );
    return mat3( c, s, 0.0,
        -s, c, 0.0,
        0.0, 0.0, 1.0 );

}

mat4 projection(vec3 pa, vec3 pb, vec3 pc, vec3 pe, float n, float f) {
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
        A, B, C, -1.,
        0, 0, D, 0.
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

vec3 position(float id) {
    // For across = 2, we want:
    // x -> [0; 6], [1; 6]
    // y -> [0; 6], [1; 6]
    // quad 0, id = 0 - 6
    // x -> 0
    // y -> 0
    // quad 1, id = 6 - 12
    // x -> 1
    // y -> 0
    // quad 2, id = 12 - 18
    // x -> 0
    // y -> 1
    float across = 100.;
    float x = mod(floor(id / 6.), across);
    float y = floor(id / (6. * across));
    float u = x / (across - 1.0);
    float v = y / (across - 1.0);
    float ux = 2. * u - 1.;
    float vy = 2. * v - 1.;
    return vec3(ux, vy, 0);
}

vec3 position_offset(float id) {
    vec3 pos = position(id);
    vec3 offset = thash33(pos.xyz);
    offset = 2. * offset - 1.;
    return offset;
}

float circleSDF(float radius, vec2 pos) {
    return length(pos) - radius;
}

void main() {
    // screen + camera setup
    float screen_width_mm = 350.90; // 14 inch
    float screen_height_mm = 247.1; //
    float head_to_screen_mm = 300.; // 1 ft
    vec3 pa = 0.5 * vec3(-screen_width_mm, -screen_height_mm, 0);
    vec3 pb = 0.5 * vec3(screen_width_mm, -screen_height_mm, 0);
    vec3 pc = 0.5 * vec3(-screen_width_mm, screen_height_mm, 0);
    vec3 pe = 1.*vec3(0, 0, head_to_screen_mm);
    float n = 0.1;
    float f = 10000.;
    mat4 P = projection(pa, pb, pc, pe, n, f);
    mat4 C = camera(pa, pb, pc, pe, n, f);

    // write the position
    float id = vertexId;
    float param = 0.5 + 0.5 * sin(time);
    vec3 world_scale = vec3(20, 20, 100);
    vec3 pos_offset = position_offset(id);
    vec3 xyz = position(id) + world_scale*pos_offset;

    float sphere_radius = 20.;
    vec3 sphere_xyz = vec3(0);
    sphere_xyz.z = -(3. * world_scale.z - mod(time, 10.) * 0.6 * world_scale.z);
    float sphere_dist = length(xyz - sphere_xyz) - sphere_radius;
    float m = 5. * sphere_radius;
    float s = 1.4 * sphere_radius + 60.0*hash11(xyz.z);
    //float s = 80.*hash11(id);
    vec3 scatter_dir = normalize(2. * hash33(pos_offset) - 1.);
    xyz.xy += scatter_dir.xy * s * smoothstep(1.*m, -1.0*m, sphere_dist);

    xyz = xyz + vec3(quad(id), 0);
    mat3 model = rotX(3.14 * -.3) * rotZ(3.14 * time * 0.5 * pos_offset.z);
    gl_Position = P * C * vec4(model * (xyz + 0.5*vec3(quad(id), 0)), 1.0);

    // write the color
    vec4 base = vec4(0.1 * hash13(position(id)));
    base.a = 0.15;
    vec4 shocked = vec4(0.4 * hsv2rgb(vec3(1. - 0.1*pos_offset.z, 1., 1.)), 0.2);
    v_color = mix(base, shocked, smoothstep(1.*m, -1.*m, sphere_dist));
}