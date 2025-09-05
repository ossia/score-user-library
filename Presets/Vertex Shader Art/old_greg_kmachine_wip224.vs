/*{
  "DESCRIPTION": "old greg kmachine wip224",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/mD6W2p47kSDX2WqK4)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 5165,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 125,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1565838653301
    }
  }
}*/



//KDrawmode=GL_TRIANGLE_STRIP
//KVertexCount=12000.

#define PI radians(180.)

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
  float rnd = 1.;
  float offset = 2. / samples;
  float increment = PI * (3. - sqrt(5.));

  // for i in range(samples):
  float y = ((i * offset) - 1.) + (offset / 2.);
  float r = sqrt(1. - pow(y ,2.));

  float phi = mod(i + rnd, samples) * increment;

  float x = cos(phi) * r;
  float z = sin(phi) * r;

  return vec3(x, y, z);
}

void getCirclePoint(const float numEdgePointsPerCircle, const float id, const float inner, const float start, const float end, out vec3 pos) {
  float outId = id - floor(id / 3.) * 2. - 1.; // 0 1 2 3 4 5 6 7 8 .. 0 1 2, 1 2 3, 2 3 4
  float ux = floor(id / 6.) + mod(id, 2.);
  float vy = mod(floor(id / 2.) + floor(id / 3.), 2.); // change that 3. for cool fx
  float u = ux / numEdgePointsPerCircle;
  float v = mix(inner, 1., vy);
  float a = mix(start, end, u) * PI * 2. + PI * 0.0;
  float s = sin(a);
  float c = cos(a);
  float x = c * v;
  float y = s * v;
  float z = 0.;
  pos = vec3(x, y, z);
}

void main() {
  float minEdge = 12.;
  float maxEdge = 12.0;
  float NUM_EDGE_POINTS_PER_CIRCLE = floor(mix(minEdge, maxEdge, sin(time * 7.) * .5 + .5));
  float mv = (NUM_EDGE_POINTS_PER_CIRCLE - minEdge) / (maxEdge - minEdge);
  float NUM_POINTS_PER_CIRCLE = (NUM_EDGE_POINTS_PER_CIRCLE * 6.0);
  float NUM_CIRCLES_PER_GROUP = 1.0;
  float circleId = floor(vertexId / NUM_POINTS_PER_CIRCLE);
  float groupId = floor(circleId / NUM_CIRCLES_PER_GROUP);
  float pointId = mod(vertexId, NUM_POINTS_PER_CIRCLE);
  float sliceId = mod(floor(vertexId / 6.), 2.);
  float side = mix(-1., 1., step(0.5, mod(circleId, 2.)));
  float numCircles = floor(vertexCount / NUM_POINTS_PER_CIRCLE);
  float numGroups = floor(numCircles / NUM_CIRCLES_PER_GROUP);
  float cu = circleId / numCircles;
  float gv = groupId / numGroups;
  float cgId = mod(circleId, NUM_CIRCLES_PER_GROUP);
  float cgv = cgId / NUM_CIRCLES_PER_GROUP;
  float ncgv = 1. - cgv;

  float aspect = resolution.x / resolution.y;
  float gAcross = floor(sqrt(numCircles) * aspect) ;
  float gDown = floor(numGroups / gAcross);
  float gx = mod(groupId, gAcross);
  float gy = floor(groupId / gAcross);
  vec3 offset = vec3(
    gx - (gAcross - 1.) / 2.,// + mod(gy, 2.) * 0.5,
    gy - (gDown - 1.) / 2.,
    0) * 0.17;

  float gs = gx / gAcross;
  float gt = gy / gDown;

  float tm = time - cgv * 0.2;
  float su = hash(groupId);
  float s = texture(sound, vec2(mix(0.01, 0.5, hash(fract(gv * 4.))), 0.)).r * 1.3;

  vec3 pos;
  float inner =mouse.y;
  float start = mouse.x;
  float end =step(0.13,0.5+s);
  getCirclePoint(NUM_EDGE_POINTS_PER_CIRCLE, pointId, inner, start, end, pos);
  pos.z = cgv;

   //vec3 loc = fibonacciSphere(numGroups, groupId);
 vec3 loc = normalize(vec3(hash(groupId * 0.4123), hash(groupId * .747), hash(groupId * .311)) * 2. - 1.);
  float rd = 50.;
  vec3 eye = vec3(0,1.2*rd,rd);//sin(time * 0.19) * rd, sin(time * 0.21) * 0., cos(time * 0.19) * rd);
  float t = time;
  vec3 target = vec3(sin(-t * .63 +s) * 10., sin(t * .4+s)*20.*s, 0.);//vec3(sin(time * 0.17), sin(time * 0.13), -10);
  vec3 up =vec3(0,1,0.5);
 // vec3(sin(time * 0.3) * 0.2, 1, 0);

  mat4 pmat = persp(radians(45.), aspect, 1., 200.);
  mat4 vmat = cameraLookAt(eye, target, up);

  float VertexCount = 50000.*(mouse.x*mouse.y);

  float sv = pow(s, .5);

  mat4 wmat = rotY(t * .017);
  wmat *= rotX(t * .13);
  wmat *= lookAt(loc * 8.5 +s *s* .1, vec3(0), up);
  wmat *= uniformScale(mix(0., 1., pow(s *1.8, 6.)));
  wmat *= rotZ(groupId * PI / 3.);

  mat4 mvMat = vmat * wmat;
  gl_Position = pmat * mvMat * vec4(pos, 1);
  gl_PointSize = 4.;

  float hue = fract(gv * 4.) * .21 + time * .1;// + groupId * 0.5;
  float sat =1.0;step(pow(s, 3.), gt);
  float val = 1.;pow(s * 1.25, 20.) + .3;// + mix(.0, 1., mod(groupId, 2.));

  //if (mvMat[2][2] < 0.0) {
  if (dot(normalize(mvMat[2].xyz), vec3(0, 0, 1)) < 0.3) {
    gl_Position.z = 100.;
  }

  vec3 nrm = normalize((wmat * vec4(0,0,1,0)).xyz);
  vec3 litDir = normalize(vec3(2,2,1));
  float lt = 1.0;;
  v_color = vec4(hsv2rgb(vec3(hue, sat, val)) * lt, 1);

  v_color.rgb /= v_color.a*s;

  float super = step(0.9, 1.-s);
  v_color = mix(v_color, vec4(s-1.,0,0,0.7), super);

}

// Removed built-in GLSL functions: transpose, inverse