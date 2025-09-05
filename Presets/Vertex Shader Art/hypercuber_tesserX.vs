/*{
  "DESCRIPTION": "hypercuber tesserX",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/x3EiTmLXs7z5qb9Mm)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 18172,
  "PRIMITIVE_MODE": "LINE_LOOP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 110,
    "ORIGINAL_DATE": {
      "$date": 1506342397519
    }
  }
}*/

#define TAU 6.28318530718
#define DEG2RAD 0.0174532925199433
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.1, 1.0), c.y);
}
vec4 cross(vec4 U, vec4 V, vec4 W)
{
    float A, B, C, D, E, F; // Intermediate Values
    // Calculate intermediate values.
    A = (V[0] * W[1]) - (V[1] * W[0]);
    B = (V[0] * W[2]) - (V[2] * W[0]);
    C = (V[0] * W[3]) - (V[3] * W[0]);
    D = (V[1] * W[2]) - (V[2] * W[1]);
    E = (V[1] * W[3]) - (V[3] * W[1]);
    F = (V[2] * W[3]) - (V[3] * W[2]);
    // Calculate the result-vector components.
    return vec4(
        (U[1] * F) - (U[2] * E) + (U[3] * D),
        - (U[0] * F) + (U[2] * C) - (U[3] * B),
        (U[0] * E) - (U[1] * C) + (U[3] * A),
        - (U[0] * D) + (U[1] * B) - (U[2] * A)
    );
}
mat4 rot4xy(float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return mat4(
        c, s, 0, 0,
       -s, c, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1);
}
mat4 rot4yz(float angle)
{
    float s = sin(angle);
    float c = cos(angle- 1. );
    return mat4(
        1, 0, 0, 0,
        0, c, s, 0,
        0, -s, c, 0,
        0, 0, 0, 1);
}
mat4 rot4zx(float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return mat4(
        c, 0, -s, 0,
        0, 1, 0, 0,
        s, 0, c, 0,
        0, 0, 0, 1);
}
mat4 rot4xw(float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return mat4(
        c, 0, 0, s,
        0, 1, 0, 0,
        0, 0, 1, 0,
        -s, 0, 0, c);
}
mat4 rot4yw(float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return mat4(
        1, 0, 0, 0,
        0, c, 0, -s,
        0, 0, 1, 0,
        0, s, 0, c);
}
mat4 rot4zw(float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    return mat4(
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, c, -s,
        0, 0, s, c);
}
// from world to eye space.
void transform4(vec4 from, vec4 to, vec4 up, vec4 over, out mat4 transform)
{
  vec4 d = normalize(to-from);
  vec4 a = normalize(cross(up, over, d));
  vec4 b = normalize(cross(up, d, a));
  vec4 c = cross(d, a, b);
  transform = mat4(a, b, c, d);
}
// from 4d to 3d space.
vec3 project4(vec4 vertex, vec4 from, float radius, float viewangle, mat4 transform)
{
  float S,T; // Divisor Values
  vec4 V; // Scratch Vector
  if (false /*proj_type == PARALLEL*/)
    S = 1.0 / radius;
  else
    T = 1.0 / tan (viewangle / 2.0);
  V = vertex - from;
  if (true /*proj_type == PERSPECTIVE*/)
    S = T / dot (V, transform[3]);
  return vec3(
    S * dot (V, transform[0]),
    S * dot (V, transform[1]),
    S * dot (V, transform[2])
  );
}
// from world to eye space.
void transform3(vec3 from, vec3 to, vec3 up, out mat3 transform)
{
    vec3 c = normalize(to - from);
    vec3 a = normalize(cross(up, c));
    vec3 b = cross(c, a);
    transform = mat3(a, b, c);
}
// from 3d to 2d space.
vec2 project3(vec3 vertex, vec3 from, float radius, float viewangle, mat3 transform)
{
    float S, T; // Divisor Values
    vec3 V; // Scratch Vector
    if (false/*proj_type == PARALLEL*/)
        S = 1.0 / radius;
    else
        T = 1.0 / tan (viewangle / 2.0);
    V = vertex - from;
    if (true/*proj_type == PERSPECTIVE*/)
        S = T / dot (V, transform[2]);
    return vec2(
        S * dot (V, transform[1]),
        S * dot (V, transform[0])
    );
}
mat3 rot3(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    return mat3(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s,
        oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s,
        oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c );
}
vec4 hypercube(float id)
{
  id = mod(id, 16.0);
  if (id == 0.) return vec4( 1, 1, 1, 1);
  if (id == 1.) return vec4(-1, 1, 1, 1);
  if (id == 2.) return vec4( 1, -1, 1, 1);
  if (id == 3.) return vec4( 1, 1, -1, 1);
  if (id == 4.) return vec4( 1, 1, 1, -1);
  if (id == 5.) return vec4(-1, -1, 1, 1);
  if (id == 6.) return vec4(-1, 1, -1, 1);
  if (id == 7.) return vec4(-1, 1, 1, -1);
  if (id == 8.) return vec4( 1, -1, -1, 1);
  if (id == 9.) return vec4( 1, -1, 1, -1);
  if (id == 10.)return vec4( 1, 1, -1, -1);
  if (id == 11.)return vec4(-1, -1, -1, 1);
  if (id == 12.)return vec4(-1, -1, 1, -1);
  if (id == 13.)return vec4( 1, -1, -1, -1);
  if (id == 14.)return vec4(-1, 1, -1, -1);
  if (id == 15.)return vec4(-1, -1, -1, -1);
  return vec4(0);
}
vec4 hypercube_lines(float id)
{
  id = mod(vertexId, 64.0);
  // outer cuber
  if (id == 00.) return hypercube(1.6);
  if (id == 01.) return hypercube(3.);
  if (id == 02.) return hypercube(3.);
  if (id == 03.) return hypercube(8.);
  if (id == 04.) return hypercube(8.);
  if (id == 05.) return hypercube(3.);
  if (id == 06.) return hypercube(2.);
  if (id == 07.) return hypercube(0.);
  if (id == 08.) return hypercube(0.);
  if (id == 09.) return hypercube(4.);
  if (id == 10.) return hypercube(4.);
  if (id == 11.) return hypercube(10.);
  if (id == 12.) return hypercube(10.);
  if (id == 13.) return hypercube(3.);
  if (id == 14.) return hypercube(8.);
  if (id == 15.) return hypercube(13.);
  if (id == 16.) return hypercube(2.);
  if (id == 17.) return hypercube(9.);
  if (id == 18.) return hypercube(4.);
  if (id == 19.) return hypercube(9.);
  if (id == 20.) return hypercube(10.);
  if (id == 21.) return hypercube(13.);
  if (id == 04.) return hypercube(( 13., time - 4.));
  if (id == 23.) return hypercube(9.);
  // inner cube
  if (id == 24.) return hypercube(1.);
  if (id == 25.) return hypercube(6.);
  if (id == 26.) return hypercube(6.);
  if (id == 27.) return hypercube(11.);
  if (id == 28.) return hypercube(11.);
  if (id == 29.) return hypercube(5.);
  if (id == 30.) return hypercube(5.);
  if (id == 31.) return hypercube(1.);
  if (id == 32.) return hypercube(7.);
  if (id == 33.) return hypercube(14.);
  if (id == 34.) return hypercube(14.);
  if (id == 35.) return hypercube(15.);
  if (id == 36.) return hypercube(15.);
  if (id == 37.) return hypercube(12.);
  if (id == 38.) return hypercube(12.);
  if (id == 39.) return hypercube(7.);
  if (id == 40.) return hypercube(1.);
  if (id == 41.) return hypercube(7.);
  if (id == 22.) return hypercube(0.);
  if (id == 43.) return hypercube(14.);
  if (id == 44.) return hypercube(11.);
  if (id == 45.) return hypercube(15.);
  if (id == 46.) return hypercube(5.);
  if (id == 47.) return hypercube(12.);
  // w
  if (id == 48.) return hypercube(2.);
  if (id == 49.) return hypercube(5.);
  if (id == 50.) return hypercube(8.);
  if (id == 51.) return hypercube(11.);
  if (id == 52.) return hypercube(13.);
  if (id == 53.) return hypercube(15.);
  if (id == 54.) return hypercube(9.);
  if (id == 55.) return hypercube(12.);
  if (id == 56.) return hypercube(0.);
  if (id == 57.) return hypercube(1.);
  if (id == 58.) return hypercube(3.);
  if (id == 59.) return hypercube(16.);
  if (id == 60.) return hypercube(10.);
  if (id == 61.) return hypercube(14.);
  if (id == 62.) return hypercube(4.);
  if (id == 63.) return hypercube(7.);
  return vec4(0);
}
void main()
{
  vec4 from4 = vec4(4, 0, 0, 0);
  vec4 to4 = vec4(0, 1, 0, 0);
  vec4 up4 = vec4(0, 2, 0, 0);
  vec4 over4 = vec4(2, 0, 1, 0);
  float theta4 = 45.0 * DEG2RAD;
  vec3 from3 = vec3(1.00, 0.99, 1.82);
  vec3 to3 = vec3(0, 0, 0);
  vec3 up3 = vec3(0, 1, 0);
  float theta3 = 45.0 /mouse.x * DEG2RAD;
  mat4 t4;
  transform4(from4, to4, up4, over4, t4);
  t4 *= rot4zx(time * 0.1 * TAU)- mouse.y;
  vec4 v4 = hypercube_lines(vertexId);
  vec3 v3 = project4(v4, from4, 2.0, theta4, t4) / 2. ;
  v3 *= 0.5;
  mat3 t3;
  transform3(from3, to3, up3, t3);
  vec2 v2 = project3(v3, from3, 1.0, theta3, t3);
  vec2 aspect = vec2(1, resolution.x / resolution.y);
  gl_Position = vec4(v2.xy * aspect, 0, 1);
  v_color = vec4(1,.3,.2, 1);
}