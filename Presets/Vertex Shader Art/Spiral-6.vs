/*{
  "DESCRIPTION": "Spiral - undecided on what to do with music on this one, but it's a start",
  "CREDIT": "sylistine (ported from https://www.vertexshaderart.com/art/rGsksAzL2wfEQZTc9)",
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
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 192,
    "ORIGINAL_DATE": {
      "$date": 1601961470683
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 4.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 5.0

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

mat4 scale(float s) {
  return mat4(
    s, 0, 0, 0,
    0, s, 0, 0,
    0, 0, s, 0,
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

mat4 rotX( float angle ) {
    float s = sin( angle );
    float c = cos( angle );

    return mat4(
      1, 0, 0, 0,
      0, c, -s, 0,
      0, s, c, 0,
      0, 0, 0, 1);
}

mat4 trans(vec3 trans) {
  return mat4(
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    trans, 1);
}

struct vertexData {
  vec3 position;
  vec2 uv;
  vec3 normal;
};

  vec3 quadPos(float vId) {
    float vIdQuad = mod(vId, 6.); // 0 1 2 3 4 5

    float vIdTri = mod(vIdQuad, 3.); // 0 1 2 0 1 2
    float tId = floor(vIdQuad / 3.); // 0 0 0 1 1 1

    float x = mod(vIdQuad, 2.); // 0 1 0 1 0 1
    float yRaw = floor(vIdTri / 2.); // 0 0 1 0 0 1
    float y = abs(yRaw - tId); // 0 0 1 1 1 0
    return vec3(x, y, 0.);
  }

vertexData get_VertexData(float vId, float vCount) {
  float triId = floor(vId / 3.);
  float triVertexId = mod(vId, 3.);
  float quadCount = floor(vCount / 6.);
  float quadIdx = floor(triId/2.);

  vec2 planeSize = vec2(floor(quadCount / 32.), 32.);
  float xId = floor(quadIdx / (planeSize.y * 2.));
  float yId = mod(quadIdx, planeSize.y * 2.);
  float zId = floor(yId / planeSize.y);
  vec3 quadId = vec3(xId, mod(yId, planeSize.y), 1.);

  float xPos = mod(vId, 2.) + quadId.x;
  float yPos = abs(floor(triVertexId / 2.) - mod(triId, 2.)) + quadId.y;

  vec3 position = vec3(xPos, yPos, (zId*2.+1.)*0.01);
  vec3 offset = vec3(-planeSize.x * 0.25, -planeSize.y*0.5, 0.);
  //vec3 position = vec3(xPos, sin(yPos/quadSize.y * PI * 2.), cos(yPos/quadSize.y * PI * 2.));
  //vec3 offset = vec3(-quadSize.x * 0.5, 0., 0.);
  position += offset;

  vec3 normal = vec3(0., 0., -1.) + vec3(0., 0., 2.)*zId;

  float spinStrength = 4.;
  mat4 spiral = rotX(((position.x+time*8.)/planeSize.x)*PI*spinStrength);
  position = (spiral * vec4(position, 1.)).xyz;

  vec2 uv = vec2(xPos/(planeSize.x+1.), yPos/(planeSize.y+1.));

  vertexData data;
  data.position = position;
  data.uv = uv;
  data.normal = (spiral * vec4(normal, 0.)).xyz;
  return data;
}

void main() {
  float vTriId = mod(vertexId, 3.);
  vertexData v = get_VertexData(vertexId, vertexCount);

  vec3 v0 = get_VertexData(vertexId - vTriId, vertexCount).position;
  vec3 v1 = get_VertexData(vertexId - (vTriId - 1.), vertexCount).position;
  vec3 v2 = get_VertexData(vertexId - (vTriId - 2.), vertexCount).position;
  vec3 e1 = v0 - v1;
  vec3 e2 = v2 - v1;
  vec3 normal = cross(e1, e2);

  normal = v.normal;
  vec2 m = mouse * PI * 0.5;
  vec3 lightPos = vec3(0., sin(m.y), -cos(m.y));
  vec3 lightDir = normalize(lightPos);
  vec3 lightColor = hsv2rgb(vec3(v.uv.x + time * 0.1, 1.0, 1.0));
  float ambientLight = 0.1;

  mat4 view = trans(vec3(0., 0., -50.));
  //mat4 proj = scale(1./pow(2., 8.));
  mat4 proj = persp(PI * 0.5, resolution.x / resolution.y, 0.1, 100.);
  gl_Position = proj * view * vec4(v.position, 1.);

  float directLightStrength = clamp(dot(normal, lightDir), 0., 1.);
  v_color = vec4(clamp(directLightStrength + ambientLight, 0.0, 1.0) * lightColor, 1.);
  //v_color = vec4(hsv2rgb(vec3(v.uv.x+time*0.5, 1.0, 1.0)), 1.);
  gl_PointSize = 1.;
}