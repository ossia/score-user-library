/*{
  "DESCRIPTION": "ball",
  "CREDIT": "gman (ported from https://www.vertexshaderart.com/art/yWSCEoXnFJxXAZyBo)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.011764705882352941,
    0.16470588235294117,
    0.8431372549019608,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 290,
    "ORIGINAL_DATE": {
      "$date": 1450502859713
    }
  }
}*/

/*

    ___ __ _
   / \\ \ /_\ _ __ ___ __ _ _ __ __ _
  / /\ / \ \ //_\\| '_ \/ __|/ _` | '__/ _` |
 / /_//\_/ / / _ \ |_) \__ \ (_| | | | (_| |
/___,'\___/ \_/ \_/ .__/|___/\__,_|_| \__,_|
        |_|

*/

#define PI radians(180.)

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat4 rotX(float angle) {

    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      1, 0, 0, 0,
      0, c, s, 0,
      0,-s, c, 0,
      0, 0, 0, 1);
}

mat4 rotY( float angle ) {
    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 1);
}

mat4 rotZ( float angle ) {
    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1);
}

mat4 trans(vec3 trans) {
  #if 0
  return mat4(
    1, 0, 0, trans[0],
    0, 1, 0, trans[1],
    0, 0, 1, trans[2],
    0, 0, 0, 1);
  #else
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    trans, 1);
  #endif
}

mat4 ident() {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1);
}

mat4 uniformScale(float s) {
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
    0, 0, 0, 1);
}

mat4 scale(vec3 s) {
  return mat4(
    s[0], 0, 0, 0,
    0, s[1], 0, 0,
    0, 0, s[2], 0,
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
float hash(float p)
{
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

float m1p1(float v) {
  return v * 2. - 1.;
}

float p1m1(float v) {
  return v * .5 + .5;
}

float inRange(float v, float minV, float maxV) {
  return step(minV, v) * step(v, maxV);
}

float at(float v, float target) {
  return inRange(v, target - 0.1, target + 0.1);
}

float hashp(float p) {
  return m1p1(hash(p));
}

#define SEGS 16.
void main() {
  float pointsPerSphere = SEGS * (SEGS * 0.5) * 6.;
  float sphereId = floor(vertexId / pointsPerSphere);
  float numSpheres = floor(vertexCount / pointsPerSphere);
  float su = sphereId / numSpheres;

  float v = mod(vertexId, pointsPerSphere);
  float vertex = mod(v, 6.);
  v = (v-vertex)/6.;
  float a1 = mod(v, SEGS);
  v = (v-a1)/SEGS;
  float a2 = v-(SEGS / 4.);

  float a1n = (a1+.5)/SEGS*2.*PI;
  float a2n = (a2+.5)/SEGS*2.*PI;

  a1 += mod(vertex,2.);
  a2 += vertex==2.||vertex>=4.?1.:0.;

  a1 = a1/SEGS*2.*PI;
  a2 = a2/SEGS*2.*PI;

  vec3 pos = vec3(cos(a1)*cos(a2),sin(a2),sin(a1)*cos(a2));
  vec3 norm = vec3(cos(a1n)*cos(a2n),sin(a2n),sin(a1n)*cos(a2n));

  float snd0 = texture(sound, vec2(su * 0.2 + 0.05, 0)).r;
  /*
  #define NUM_SAMPLES 8
  float csnd = 0.;
  for (int i = 0; i < NUM_SAMPLES; ++i) {
    csnd += texture(sound, vec2(0.05, float(i) / float(NUM_SAMPLES) * 0.1)).r;
  }
  csnd /= float(NUM_SAMPLES);
  */
  float csnd = 0.;
  float cangle = time + csnd * PI * 2.;
  float c = cos(cangle);
  float s = sin(cangle);
  float r = 1.5;
  vec3 cameraPos = vec3(c * r, sin(time * 0.57), s * r);
  vec3 cameraTarget = vec3(0, 0, 0);
  vec3 cameraUp = vec3(0, 1, 0);

  mat4 p = persp(radians(65.), resolution.x / resolution.y, 0.1, 100.);
  mat4 cam = lookAt(cameraPos, cameraTarget, cameraUp);
  mat4 view = inverse(cam);

  mat4 w = trans(vec3(hashp(sphereId * 0.43), hashp(sphereId * 1.39), hashp(sphereId * 2.11)));
  w *= uniformScale(mix(1.1, 2.5, hash(sphereId * 0.37)) * pow(snd0, 5.)) ;
  w *= rotX(hash(sphereId * 0.791) * PI * 2.);
  gl_Position = p * view * w * vec4(pos, 1);

  vec3 lightDir = normalize(vec3(1.1, 2.0, 2.0));
  lightDir = normalize((cam * vec4(lightDir, 0)).xyz);
  norm = normalize((w * vec4(norm, 0)).xyz);
  float light = mix(0.5, 1., abs(dot(norm, lightDir)));

  float hue = mix(0.95, 1.00, hash(sphereId));
  float sat = mix(1.4, 1.7, hash(sphereId * 6.131));
  float val = light;
  v_color = vec4(
    mix(hsv2rgb(vec3(hue, sat, val)),
        vec3(1,1,1),
        step(10.9, snd0)), 1);
}
// Removed built-in GLSL functions: transpose, inverse