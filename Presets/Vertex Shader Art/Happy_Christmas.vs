/*{
  "DESCRIPTION": "Happy_Christmas",
  "CREDIT": "evan_chen (ported from https://www.vertexshaderart.com/art/5CPofs7dnZ8Pd7KNv)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 4900,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.2627450980392157,
    0.2627450980392157,
    0.2627450980392157,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 179,
    "ORIGINAL_DATE": {
      "$date": 1577521407073
    }
  }
}*/

/**

        .___ __ .
        [__ . , _.._ / `|_ _ ._
        [___ \/ (_][ )____\__.[ )(/,[ )

        .__ . ._ .. .
        [__)*\./ _ | |, _.||*._ _ _| _ . ,._
        | |/'\(/,| | (_]|||[ )(_] (_](_) \/\/ [ )
        ._|

        . . __ . ,
        |__| _.._ ._ . / `|_ ._.* __-+-._ _ _. __
        | |(_][_)[_)\_| \__.[ )[ |_) | [ | )(_]_)
        | | ._|

@24/12/2019
*/

#define PI radians(180.0)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat4 rotX(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      1, 0, 0, 0,
      0, c, s, 0,
      0, -s, c, 0,
      0, 0, 0, 1);
}

mat4 rotY(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 1);
}

mat4 rotZ(float angleInRadians) {
    float s = sin(angleInRadians);
    float c = cos(angleInRadians);

    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1);
}

mat4 trans(vec3 trans) {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    trans, 1);
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0, 0,
    0, s[1], 0, 0,
    0, 0, s[2], 0,
    0, 0, 0, 1);
}

mat4 uniformScale(float s) {
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
    0, 0, 0, 1);
}

mat4 persp(float fov, float aspect, float zNear, float zFar) {
  float f = tan(PI * 0.5 - 0.5 * fov);
  float rangeInv = 1.0 / (zNear - zFar);

  return mat4(
    f / aspect, 0, 0, 0,
    0, f, 0, 0,
    0, 0, (zNear + zFar) * rangeInv, -1,
    0, 0, zNear * zFar * rangeInv * 2., 0);
}

mat4 trInv(mat4 m) {
  mat3 i = mat3(
    m[0][0], m[1][0], m[2][0],
    m[0][1], m[1][1], m[2][1],
    m[0][2], m[1][2], m[2][2]);
  vec3 t = -i * m[3].xyz;

  return mat4(
    i[0], t[0],
    i[1], t[1],
    i[2], t[2],
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

mat4 cameraLookAt(vec3 eye, vec3 target, vec3 up) {
  #if 1
  return inverse(lookAt(eye, target, up));
  #else
  vec3 zAxis = normalize(target - eye);
  vec3 xAxis = normalize(cross(up, zAxis));
  vec3 yAxis = cross(zAxis, xAxis);

  return mat4(
    xAxis, 0,
    yAxis, 0,
    zAxis, 0,
    -dot(xAxis, eye), -dot(yAxis, eye), -dot(zAxis, eye), 1);
  #endif

}

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p) {
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

// times 2 minus 1
float t2m1(float v) {
  return v * 2. - 1.;
}

// times .5 plus .5
float t5p5(float v) {
  return v * 0.5 + 0.5;
}

float inv(float v) {
  return 1. - v;
}

vec3 randomPos(in float id)
{
  return vec3( ( 1.5) * 1. * (hash(id * 0.171)) + 0.05 * sin(2. * time * mix(0.91, 0.2, hash(id * 0.951))) ,
        mix(1.5, -1.5, fract(hash(id * .654) + time * mix(0.01, 0.03, hash(id * 0.543)))),
        1.0 ) * 20. ;
}
vec3 randomScale(in float id)
{
  return vec3(( 1.5) * 1. * (hash(id * 0.171)) + 0.05 * sin(2. * time * mix(0.91, 0.2, hash(id * 0.951))) ,
        mix(1.5, -1.5, fract(hash(id * .654) + time * mix(0.01, 0.03, hash(id * 0.543)))),
        1.)* 20. ;
}

/* -------------------------------- seperater ------------------------------- */

/* -------------------------------- seperater ------------------------------- */

void main()
{

  vec3 pos = vec3(0. ) ;

  mat4 mat = persp(radians(60.0), resolution.x / resolution.y, 0.01, 100.0);

  mat4 mmat = trans(vec3(0, 0, 13));
  mat *= mmat ;
  vec3 n = normalize(
      vec3(
        hash(vertexId * 0.123),
        hash(vertexId * 0.357),
        hash(vertexId * 0.531)
      ) * 2. - 1.
    );
  //

  if(vertexId < 10000.)
  {
    mat *= trans(n * 84.) ;
    mat *= trans(randomPos(vertexId)) ;
    mat *= scale(randomScale(vertexId));

    gl_Position = mat * vec4(pos , 1.) * 1.;
    gl_PointSize = 10.;
    v_color = vec4(hash(vertexId )) ;
  }
}


// Removed built-in GLSL functions: transpose, inverse