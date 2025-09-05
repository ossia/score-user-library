/*{
  "DESCRIPTION": "unnamed",
  "CREDIT": "archer (ported from https://www.vertexshaderart.com/art/GEtBB56A9P7F4wjdG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 100,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1550170457066
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.
#define NUM_POINTS (NUM_SEGMENTS * 2.)
#define STEP 1.

vec4 quatFromAxisAngle(vec3 axis, float angle) {
  vec4 qr;

  float half_angle = angle/2.;
  qr.x = axis.x * sin(half_angle);
  qr.y = axis.y * sin(half_angle);
  qr.z = axis.z * sin(half_angle);
  qr.w = cos(half_angle);

  return qr;
}

vec4 quatFromPos(vec3 pos) {
  vec4 qp;

  qp.x = pos.x;
  qp.y = pos.y;
  qp.z = pos.z;
  qp.w = 0.;

  return qp;
}

vec4 quatInverse(vec4 q) {
 return vec4(-q.x, -q.y, -q.z, q.w);
}

vec4 quatMultiply(vec4 q1, vec4 q2) {
  vec4 q;

  q.x = (q1.w * q2.x) + (q1.x * q2.w) + (q1.y * q2.z) - (q1.z * q2.y);
  q.y = (q1.w * q2.y) - (q1.x * q2.z) + (q1.y * q2.w) + (q1.z * q2.x);
  q.z = (q1.w * q2.z) + (q1.x * q2.y) - (q1.y * q2.x) + (q1.z * q2.w);
  q.w = (q1.w * q2.w) - (q1.x * q2.x) - (q1.y * q2.y) - (q1.z * q2.z);

  return q;
}

vec3 rotatePosAboutAxle(vec3 pos, vec3 axis, float angle) {
  vec4 qr = quatFromAxisAngle(axis, angle);
  vec4 qp = quatFromPos(pos);
  vec4 qi = quatInverse(qr);

  vec4 qtemp = quatMultiply(qr, qp);
  qtemp = quatMultiply(qtemp, qi);

  return qtemp.xyz;
}

vec3 rotatePosXYZ(vec3 pos, vec3 angle) {
  vec3 rotPos = vec3(pos);

  rotPos = rotatePosAboutAxle(rotPos, vec3(0, 0, 1), angle.z);
  rotPos = rotatePosAboutAxle(rotPos, vec3(0, 1, 0), angle.y);
  rotPos = rotatePosAboutAxle(rotPos, vec3(1, 0, 0), angle.x);

  return rotPos;
}

void getVertInQuad(const float vert, out float quadId, out vec2 inQuadPos) {

  float inQuadId = mod(vert, 6.);

  if (inQuadId == 0.) {
    inQuadPos = vec2(0, 0);
  } else if (inQuadId == 1.) {
    inQuadPos = vec2(1, 0);
  } else if (inQuadId == 2.) {
    inQuadPos = vec2(0, 1);
  } else if (inQuadId == 3.) {
    inQuadPos = vec2(1, 0);
  } else if (inQuadId == 4.) {
    inQuadPos = vec2(1, 1);
  } else if (inQuadId == 5.) {
    inQuadPos = vec2(0, 1);
  }

  inQuadPos -= 0.5;

  quadId = floor(vert / 6.);
}

void getQuadInBox(const float quadId, out float boxId, out vec3 quadPos, out vec3 quadAngle) {
  boxId = floor(quadId / 6.0);

  quadAngle = vec3(0., 0., 0.);

  if (boxId == 0.) {
    quadPos = vec3(0, 0, 1);
  } else if (boxId == 1.) {
 quadPos = vec3(1, 0, 0);
    quadAngle.y = PI / 2.;
  } else if (boxId == 2.) {
 quadPos = vec3(0, 0, -1);
    quadAngle.y = PI;
  } else if (boxId == 3.) {
 quadPos = vec3(-1, 0, 0);
    quadAngle.y = PI * 3. / 2.;
  } else if (boxId == 4.) {
 quadPos = vec3(0, 1, 0);
    quadAngle.x = PI * 3. / 2.;
  } else if (boxId == 5.) {
 quadPos = vec3(0, -1, 0);
    quadAngle.x = PI * 1. / 2.;
  }

  quadPos /= 2.;
}

void main() {
  float quadId;
  vec2 vertPos;
  getVertInQuad(vertexId, quadId, vertPos);

  float boxId;
  vec3 quadPos;
  vec3 quadRot;
  getQuadInBox(quadId, boxId, quadPos, quadRot);

  vec3 truePos = rotatePosXYZ(vec3(vertPos, 0.), quadRot);
  truePos += quadPos;
  truePos = rotatePosAboutAxle(truePos, vec3(0, 1, 1), mod(time / 5., 2. * PI));
  truePos *= 0.1;

  truePos.z -= .5;

  gl_Position = vec4(truePos, 1.);
  v_color = vec4(1., 1., 1., 1.);
}