/*{
  "DESCRIPTION": "galax-z",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/odJ6uwG5QzaD47cTh)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Particles"
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
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 189,
    "ORIGINAL_DATE": {
      "$date": 1555602789999
    }
  }
}*/

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

// adapted from http://stackoverflow.com/a/26127012/128511

vec3 fibonacciSphere(float samples, float i) {
  float rnd = .5;
  float offset = 2. / samples;
  float increment = PI * (3. - sqrt(5.));

  // for i in range(samples):
  float y = ((i * offset) - 1.) + (offset / 2.);
  float r = sqrt(1. - pow(y ,2.));

  float phi = mod(i + rnd, samples) * increment;

  float x = cos(phi) * r * 419.;
  float z = sin(phi) * r * 137.;

  return vec3(x, y, z);
}

float easeInOutPow(float pos, float pw) {
  if ((pos /= 0.5) < 1.) {
    return 0.5 * pow(pos, pw);
  }
  return 0.5 * (pow((pos - 2.), pw) + 2.);
}

void main() {
  vec3 pos = vec3(0, 0, 0);
  //pos *= vec3(100, 100, 10);

  mat4 mat = persp(radians(60.0), resolution.x / resolution.y, 0.01, 100.0);
  float tm = time * -0.05;
  float t2 = time * 0.05;
  float t3 = time * 0.04;
  float r = mix(10., 5., sin(t3) * .5 + .5);
  vec3 eye = vec3(cos(tm) * r, sin(t2) * 2. + 3., sin(tm) * r);
  vec3 target = vec3(0, sin(t2) * -2.5, 0);
  vec3 up = vec3(0, 1, 0);
  mat *= cameraLookAt(eye, target, up);

  vec3 n = normalize(
        vec3(
        hash(vertexId * 0.123),
        hash(vertexId * 0.357),
        hash(vertexId * 0.531)
        ) * 2. - 1.
      );

  if (vertexId < 5000.0) {
    mat *= trans(n * 84.);

    gl_Position = mat * vec4(pos, 1);
    gl_PointSize = 1.25;;
    v_color = vec4(hash(vertexId * 0.211));
  } else {
    float d = hash(vertexId * 0.713);// * (sin(vertexId * 1.5) * .5 + .5);

    float s = texture(sound, vec2(d * .1, 0)).r;

    mat *= rotY(time * mix(0.01, 0.3, (1. - d)) + sin(atan(n.x,n.z) * 20.));
    mat *= scale(vec3(10, easeInOutPow((1. - d), 4.) * 5., 10));
    mat *= trans(n * pow(d, 3.));
    gl_Position = mat * vec4(pos, 1);

    vec4 f = mat * vec4(1,1,pos.z,1);
    f = f / f.w;

    gl_PointSize = mix(1.5, 2.5, (1. - d)); //f.y * 0.5;
    float hue = mix(0.4, 0.8, s);
    float sat = 0.45;
    float val = mix(1., 1., s);
    v_color = vec4(hsv2rgb(vec3(hue,sat,val)), pow(1.-d, 0.2));
  }
  v_color.rgb *= v_color.a;
}
// Removed built-in GLSL functions: transpose, inverse