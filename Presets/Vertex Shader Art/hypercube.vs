/*{
  "DESCRIPTION": "hypercube",
  "CREDIT": "sap (ported from https://www.vertexshaderart.com/art/DP7wFzXhDCPCpGfuF)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 64,
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
    "ORIGINAL_VIEWS": 157,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1448751371138
    }
  }
}*/

#define TAU radians( 360. )
#define PI radians( 180. )
#define DEG2RAD 0.0174532925199433

/*
  http://steve.hollasch.net/thesis/
*/

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 cross(vec4 u, vec4 v, vec4 w)
{
    float a, b, c, d, e, f;

    a = (v[0] * w[1]) - (v[1] * w[0]);
    b = (v[0] * w[2]) - (v[2] * w[0]);
    c = (v[0] * w[3]) - (v[3] * w[0]);
    d = (v[1] * w[2]) - (v[2] * w[1]);
    e = (v[1] * w[3]) - (v[3] * w[1]);
    f = (v[2] * w[3]) - (v[3] * w[2]);

    return vec4(
        (u[1] * f) - (u[2] * e) + (u[3] * d),
        - (u[0] * f) + (u[2] * c) - (u[3] * b),
        (u[0] * e) - (u[1] * c) + (u[3] * a),
        - (u[0] * d) + (u[1] * b) - (u[2] * a)
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

mat4 lookAt4(vec4 from, vec4 to, vec4 up, vec4 over)
{
  vec4 d = normalize(to-from);
  vec4 a = normalize(cross(up, over, d));
  vec4 b = normalize(cross(up, d, a));
  vec4 c = cross(d, a, b);
  return mat4(a, b, c, d);
}

// from 4d to 3d space.
vec4 project4(vec4 vertex, vec4 from, float fov, mat4 transform)
{
  float S,T; // Divisor Values
  vec4 V; // Scratch Vector

  T = 1.0 / tan (fov * 0.5 * DEG2RAD);
  V = vertex - from;
  S = T / dot (V, transform[3]);

  return vec4(
    S * dot (V, transform[0]),
    S * dot (V, transform[1]),
    S * dot (V, transform[2]),
    0
  );
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1);
}

mat4 lookAt(vec3 eye, vec3 target, vec3 up) {
  vec3 zAxis = normalize(eye - target);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 0,
    yAxis, 0,
    zAxis, 0,
    eye, 1);
}

mat4 persp(float fov, float aspect, float zNear, float zFar) {
  float f = tan(0.5 * fov * DEG2RAD);
  float rangeInv = 1.0 / (zNear - zFar);

  return mat4(
    f / aspect, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (zNear + zFar) * rangeInv, -1,
    0, 0, zNear * zFar * rangeInv * 2., 0);
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
  id = mod(id, 64.0);

  // outer cuber
  if (id == 00.) return hypercube(0.);
  if (id == 01.) return hypercube(3.);
  if (id == 02.) return hypercube(3.);
  if (id == 03.) return hypercube(8.);
  if (id == 04.) return hypercube(8.);
  if (id == 05.) return hypercube(2.);
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
  if (id == 22.) return hypercube(13.);
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
  if (id == 42.) return hypercube(6.);
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
  if (id == 59.) return hypercube(6.);
  if (id == 60.) return hypercube(10.);
  if (id == 61.) return hypercube(14.);
  if (id == 62.) return hypercube(4.);
  if (id == 63.) return hypercube(7.);
  return vec4(0);
}

void main()
{
  vec4 from4 = vec4(4, 0, 0, 0);
  vec4 to4 = vec4(0, 0, 0, 0);
  vec4 up4 = vec4(0, 1, 0, 0);
  vec4 over4 = vec4(0, 0, 1, 0);

  vec3 from3 = vec3(cos(PI * mouse.x), 0.3, sin(PI * mouse.x));
  vec3 to3 = vec3(0, 0, 0);
  vec3 up3 = vec3(0, 1, 0);

  mat4 m1 = ident();
  m1 *= lookAt4(from4, to4, up4, over4);
  m1 *= rot4xy(time * 0.1 * TAU);

  vec4 v4 = hypercube_lines(vertexId);
  vec4 v3 = project4(v4, from4, 45.0, m1);

  mat4 m2 = ident();
  m2 *= lookAt(from3, to3, up3);
  m2 *= persp(45., resolution.x / resolution.y, 0.1, 60.);
  vec4 v = v3 * m2 * 1.5;

  gl_Position = vec4(v.xy, 0, 1);
  v_color = vec4(0);
  v_color += vec4(vec3(1,0,0)*(1. - v4.x), 1);
  v_color += vec4(vec3(0,0,1)*(v4.x), 1);
}
