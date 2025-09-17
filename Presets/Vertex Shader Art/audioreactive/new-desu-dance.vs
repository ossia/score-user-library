/*{
  "DESCRIPTION": "new-desu-dance - Still in vogue to be dead.\n\nstole a bunch of boilerplate from gman",
  "CREDIT": "sylistine (ported from https://www.vertexshaderart.com/art/iJobHmTq8ahMEWFSG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Effects"
  ],
  "POINT_COUNT": 57536,
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
    "ORIGINAL_VIEWS": 181,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1600668508426
    }
  }
}*/

#define PI radians(180.)
#define TAU radians(360.)
#define CircleDepth 16.0;

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
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

mat4 rotY( float angle ) {
    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
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

vec2 circleVertexPos(float vertexId) {
  float theta = PI * 2.0 / CircleDepth;

  float triId = floor(vertexId / 3.0);
  float triVertexId = mod(vertexId, 3.0);
  float thetaMultiplier = triId + triVertexId;

  float t = theta * thetaMultiplier;
  float r = step(triVertexId, 1.5);

  return vec2(cos(t), sin(t)) * r;
}

void main() {
  vec3 cameraPos = vec3(0.0, 0.0, 0.0);

  float vPerCircle = 3.0 * CircleDepth;
  float cId = floor(vertexId / vPerCircle);
  float circleCount = floor(vertexCount / vPerCircle);
  float gridWidth = 54.;
  vec2 gridSize = vec2(gridWidth, floor(circleCount / gridWidth));
  vec2 gridId = vec2(mod(cId, gridSize.x), floor(cId / gridSize.x));
  gridId -= gridSize*0.5;
  vec2 gridUv = gridId / (gridSize * 0.5);
  float centerDist = length(gridId);

  float angle = atan(abs(gridId.x), gridId.y) / (PI);
  float blurAngle = PI / 128.;

  vec2 sUV = vec2(angle, 0.0);
  sUV.y *= 0.1;
  sUV.x *= 0.33;

  int iterId = 1;
  sUV.x -= blurAngle * 0.0 * 0.5;
  float snd = 0.0;
  for (int i = 0; i <= 0; i++) {
    if (sUV.x < 0.0) {
      sUV.x += blurAngle;
      continue;
    }
    if (sUV.x > 1.0) {
      break;
    }
    float strength = 1.0 / float(iterId);
    snd = snd * (1.0 - strength) + texture(sound, sUV).r * strength;
    sUV.x += blurAngle;
    iterId++;
  }

  snd *= 0.8+sUV.x; // enhance strength of high-end values
  snd = smoothstep(0.2, 0.8, snd);
  snd = pow(snd, 4.); // enhance enhance enhance

  vec3 circlePos = vec3(gridId, 20.-snd-centerDist);
  //vec3 circleNormal = cameraPos - circlePos;

  vec3 vertexPos = vec3(circleVertexPos(vertexId), 0.0);
  //vertexPos *= mix(0.25, sqrt(2.), pow(snd, 2.0));

  mat4 P = persp(PI*0.5, resolution.x / resolution.y, 0.1, 100.);
  float sinT = sin(time*0.25)*0.0625*PI;
  vec4 lookDir = (rotY(sinT) * vec4(0.0, 0.0, 1.0, 1.0));
  mat4 V = cameraLookAt(cameraPos, lookDir.xyz, vec3(0.0, 1.0, 0.0));

  gl_Position = P * V * vec4(vertexPos + circlePos, 1.0);
  v_color = vec4(snd, 0.0, 0.0, 1.0);
  //v_color = vec4(hsv2rgb(vec3(snd, 1.0, 1.0)), 1.0);
}
// Removed built-in GLSL functions: inverse