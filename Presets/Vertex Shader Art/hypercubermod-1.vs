/*{
  "DESCRIPTION": "hypercubermod",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/mmoaXfjg9s32v5Cpw)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 5000,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 60,
    "ORIGINAL_DATE": {
      "$date": 1610788293038
    }
  }
}*/

#define TAU 6.28318530718
#define DEG2RAD 0.0174532925199433
vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
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
    float c = cos(angle);
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

float norm(float n)
{
    if (n >= 0.49)
        return 1.;
    else
        return 0.;
}

float getb(float n, float pos)
{
    return norm(mod(n / (pos * 2.), 1.0));
}

float round(float n)
{
  return floor(n + .5);
}

float not(float n)
{
  return floor(n * -1. + 1.);
}

vec4 hypercube_lines(float id)
{
  // outer cuber
    float F = getb(id, 1.);
    float E = getb(id, 2.);
    float D = getb(id, 4.);
    float C = getb(id, 8.);
    float B = getb(id, 16.);
    float A = getb(id, 32.);

    float FA = B*not(C)*not(D)*F+A*not(B)*C*not(E)+not(A)*C*D*F+B*not(C)*not(E)*F+not(A)*B*E*F+not(A)*B*D*E+A*not(B)*not(E)*not(F)+A*B*not(D)*not(E)*F+not(A)*B*C*not(E)*not(F)+B*C*D*E*F+A*not(B)*not(C)*E*F+A*B*not(C)*D*not(F)+not(A)*not(C)*not(D)*not(E)*F+A*not(B)*C*D*not(F)+not(A)*not(B)*not(C)*not(D)*E*not(F)+A*B*C*not(D)*E*not(F);
    float FB = C*not(D)*E*F+not(B)*C*D*not(E)+C*D*not(E)*not(F)+B*C*not(D)*E+A*not(B)*not(D)*F+A*not(B)*not(D)*E+A*not(D)*E*F+not(A)*not(B)*not(C)*not(E)*F+not(A)*not(B)*not(C)*E*not(F)+not(A)*B*not(C)*not(E)*not(F)+B*not(C)*not(D)*not(E)*not(F)+not(A)*B*C*not(D)*F+A*not(B)*not(C)*not(E)*not(F)+A*not(B)*not(C)*E*F+A*B*D*not(E)*F+A*B*C*E*F;
    float FC = A*D*F+A*not(B)*not(C)+A*not(B)*F+A*not(C)*D*not(E)+A*not(C)*not(E)*F+B*D*not(E)*F+not(A)*B*E*not(F)+A*C*D*E+A*C*E*F+not(B)*C*not(D)*E*not(F)+not(B)*C*D*E*F+not(A)*C*not(D)*not(E)*F;
    float FD = D*not(E)*not(F)+B*not(C)*D+A*D*not(E)+not(A)*not(D)*E*F+not(C)*not(D)*E*F+not(B)*C*E*F+not(A)*B*not(C)*F+A*not(C)*E*not(F)+not(A)*not(B)*C*D*not(F)+A*not(B)*not(C)*not(D)*F;

    FA = norm(FA);
    FB = norm(FB);
    FC = norm(FC);
    FD = norm(FD);

  float FF = mod(FA + FB * 2. + FC * 4. + FD * 8., 16.);

  return hypercube(FF);
}
void main()
{
  vec4 from4 = vec4(4, 0, 0, 0);
  vec4 to4 = vec4(0, 0, 0, 0);
  vec4 up4 = vec4(0, 1, 0, 0);
  vec4 over4 = vec4(0, 0, 1, 0);
  float theta4 = 45.0 * DEG2RAD;
  vec3 from3 = vec3(3.00, 0.99, 1.82);
  vec3 to3 = vec3(0, 0, 0);
  vec3 up3 = vec3(0, 1, 0);
  float theta3 = 45.0 * DEG2RAD;
  mat4 t4;
  transform4(from4, to4, up4, over4, t4);
  t4 *= rot4zx(time * 0.1 * TAU);
  vec4 v4 = hypercube_lines(mod(vertexId, 64.0));
  vec3 v3 = project4(v4, from4, 1.0, theta4, t4);
  v3 *= 0.5;
  mat3 t3;
  transform3(from3, to3, up3, t3);
  vec2 v2 = project3(v3, from3, 1.0, theta3, t3);
  vec2 aspect = vec2(1, resolution.x / resolution.y);
  gl_Position = vec4(v2.xy * aspect, 0, 1);
  v_color = vec4(1,1,1, 1);
}