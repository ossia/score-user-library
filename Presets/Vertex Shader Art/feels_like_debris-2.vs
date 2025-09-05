/*{
  "DESCRIPTION": "feels like debris",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/HW98dGDbChYw2FjpS)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 50400,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.5725490196078431,
    0.5725490196078431,
    0.5725490196078431,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1067,
    "ORIGINAL_LIKES": 5,
    "ORIGINAL_DATE": {
      "$date": 1449637404873
    }
  }
}*/

#define PI05 1.570796326795
#define PI 3.1415926535898

vec3 hash3(vec3 v) {
  return fract(sin(v * vec3(43758.5453123, 12345.6789012,76543.2109876)));
}

vec3 rotX(vec3 p, float rad) {
  vec2 sc = sin(vec2(rad, rad + PI05));
  vec3 rp = p;
  rp.y = p.y * sc.y + p.z * -sc.x;
  rp.z = p.y * sc.x + p.z * sc.y;
  return rp;
}

vec3 rotY(vec3 p, float rad) {
  vec2 sc = sin(vec2(rad, rad + PI05));
  vec3 rp = p;
  rp.x = p.x * sc.y + p.z * sc.x;
  rp.z = p.x * -sc.x + p.z * sc.y;
  return rp;
}

vec3 rotZ(vec3 p, float rad) {
  vec2 sc = sin(vec2(rad, rad + PI05));
  vec3 rp = p;
  rp.x = p.x * sc.x + p.y * sc.y;
  rp.y = p.x * -sc.y + p.y * sc.x;
  return rp;
}

vec4 perspective(vec3 p, float fov, float near, float far) {
  vec4 pp = vec4(p, -p.z);
  pp.xy *= vec2(resolution.y / resolution.x, 1.0) / tan(radians(fov * 0.5));
  pp.z = (-p.z * (far + near) - 2.0 * far * near) / (far - near);
  return pp;
}

vec3 lookat(vec3 p, vec3 eye, vec3 look, vec3 up) {
  vec3 z = normalize(eye - look);
  vec3 x = normalize(cross(up, z));
  vec3 y = cross(z, x);
  vec4 pp = mat4(x.x, y.x, z.x, 0.0, x.y, y.y, z.y, 0.0, x.z, y.z, z.z, 0.0, 0.0, 0.0, 0.0, 1.0) *
    mat4(1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -eye.x, -eye.y, -eye.z, 1.0)
    * vec4(p, 1.0);
  return pp.xyz;
}

vec3 lissajous(vec3 a, float t) {
  return vec3(sin(t * a.x), sin(t * a.y), cos(t * a.z));
}

// vid : 0 to 36 (6 faces * 6 vertices), ni: (normal.xyz, faceId)
#define kCubeVertexCount 36.0
vec3 cubeVertex(float vid, out vec4 ni) {
  float faceId = floor(vid / 6.0);
  float vtxId = mod(vid, 6.0);
  vec2 fp;
  vec3 p;

  if(vtxId <= 1.0) {
    fp = vec2(1.0, 1.0);
  }
  else if(vtxId == 2.0) {
    fp = vec2(-1.0, 1.0);
  }
  else if(vtxId == 3.0) {
    fp = vec2(1.0, -1.0);
  }
  else {
    fp = vec2(-1.0, -1.0);
  }

  if(faceId == 0.0) {
    // front
    p = vec3(fp.x, fp.y, 1.0);
    ni = vec4(0.0, 0.0, 1.0, faceId);
  }
  else if(faceId == 1.0) {
    // back
    p = vec3(-fp.x, fp.y, -1.0);
    ni = vec4(0.0, 0.0, -1.0, faceId);
  }
  else if(faceId == 2.0) {
    // top
    p = vec3(fp.x, 1.0, -fp.y);
    ni = vec4(0.0, 1.0, 0.0, faceId);
  }
  else if(faceId == 3.0) {
    // bottom
    p = vec3(fp.x, -1.0, fp.y);
    ni = vec4(0.0, 0.0, -1.0, faceId);
  }
  else if(faceId == 4.0) {
    // right
    p = vec3(-1.0, fp.y, -fp.x);
    ni = vec4(-1.0, 0.0, 0.0, faceId);
  }
  else {
    // left
    p = vec3(1.0, fp.y, fp.x);
    ni = vec4(1.0, 0.0, 0.0, faceId);
  }

  return p;
}

vec3 shade(vec3 eye, vec3 p, vec3 n, vec3 dfscol, float amb, vec2 spec) {
  vec3 rgb;
  vec3 lit = normalize(vec3(1.0, 1.0, 4.0));

  float diffuse = max(0.0, dot(n, lit)) * (1.0 - amb) + amb;

  vec3 h = normalize(normalize(eye - p) + lit);
  float specular = 0.0;
  if(diffuse > 0.0) {
    specular = max(0.0, pow(dot(n, h), spec.x));
  }

  rgb = diffuse * dfscol + specular * spec.y;

  return rgb;
}

void main() {
  float shapeCount = floor(vertexCount / kCubeVertexCount);
  float shapeId = floor(vertexId / kCubeVertexCount);
  float shapeVertexId = mod(vertexId, kCubeVertexCount);
  float lineId = mod(shapeId, 3.0);

  vec3 lineFactor;
  vec3 color;

  if(lineId == 0.0) {
    lineFactor = vec3(4.1, 6.7, 2.3);
    color = vec3(1.0, 0.0, 0.0);
  }
  else if(lineId == 1.0) {
    lineFactor = vec3(4.8, 5.2, 8.3);
    color = vec3(0.0, 1.0, 0.0);
  }
  else {
    lineFactor = vec3(6.1, 1.2, 3.6);
    color = vec3(0.0, 0.0, 1.0);
  }

  float t = shapeId / shapeCount;

  float aspect = resolution.x / resolution.y;
  vec4 cubeni;
  vec3 cubep = cubeVertex(shapeVertexId, cubeni) * 0.04;

  vec3 cubeHash = hash3(vec3(log(shapeId)));
  vec3 cubeOffset = (cubeHash * 2.0 - 1.0) * 0.1;
  vec3 cubeRot = hash3(cubeHash) * time * 2.0;

  cubep = rotX(rotY(rotZ(cubep, cubeRot.z), cubeRot.y), cubeRot.z);
  cubeni.xyz = rotX(rotY(rotZ(cubeni.xyz, cubeRot.z), cubeRot.y), cubeRot.z);

  cubep = lissajous(lineFactor, (t + time * 0.1) * 2.0) * vec3(aspect, 1.0, aspect) + (cubep + cubeOffset);

  /*
  if(cubeni.w == 0.0) {
    color = vec3(1.0, 0.0, 0.0);
  }
  else if(cubeni.w == 1.0) {
    color = vec3(0.0, 1.0, 0.0);
  }
  else if(cubeni.w == 2.0) {
    color = vec3(0.0, 0.0, 1.0);
  }
  else if(cubeni.w == 3.0) {
    color = vec3(1.0, 1.0, 0.0);
  }
  else if(cubeni.w == 4.0) {
    color = vec3(1.0, 0.0, 1.0);
  }
  else {
    color = vec3(0.0, 1.0, 1.0);
  }
  */

  //vec3 eye = rotX(rotY(vec3(0.0, 0.0, 3.0), -mouse.x * 2.0), mouse.y);
  vec3 eye = vec3(0.0, 0.0, 3.0);

  color = shade(eye, cubep, cubeni.xyz, vec3(0.5 + cubeHash * 0.05), 0.1, vec2(64.0, 0.8));

  vec3 p = lookat(cubep, eye, vec3(0.0), vec3(0.0, 1.0, 0.0));
  gl_Position = perspective(p, 60.0, 0.1, 10.0);
  gl_PointSize = 20.0;

  v_color = vec4(color, 1.0);
}