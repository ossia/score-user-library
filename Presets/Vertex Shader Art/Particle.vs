/*{
  "DESCRIPTION": "Particle",
  "CREDIT": "gaz (ported from https://www.vertexshaderart.com/art/FvWzPMiZrdqtgEJHY)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Abstract"
  ],
  "POINT_COUNT": 500,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 307,
    "ORIGINAL_DATE": {
      "$date": 1458810539228
    }
  }
}*/


vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat4 perspective(in float fovy, in float aspect, in float near, in float far) {
    float top = near * tan(radians(fovy * 0.5));
    float right = top * aspect;
    float u = right * 2.0;
    float v = top * 2.0;
    float w = far - near;
    return mat4(
        near * 2.0 / u, 0.0, 0.0, 0.0, 0.0,
        near * 2.0 / v, 0.0, 0.0, 0.0, 0.0,
        -(far + near) / w, -1.0, 0.0, 0.0,
        -(far * near * 2.0) / w, 0.0
    );
}

float hash(in float n) {
    return fract(sin(n)*753.5453123);
}

vec3 hash31(in float n) {
    return vec3(hash(n * 0.123), hash(n * 0.456), hash(n * 0.789));
}

void main() {
 mat4 pMatrix = perspective(45.0, resolution.x/resolution.y, 0.1, 100.0);
   mat4 vMatrix = mat4(1.0);
   vMatrix[3].z = -3.5;
    vec3 p = hash31(vertexId * 12.12 + 34.34) * 2.0 - 1.0;
    vec3 v = hash31(vertexId * 56.56 + 78.78) * 2.0 - 1.0;
   p = abs(fract(p + v * time * 0.3) * 2.0 - 1.0) * 2.0 - 1.0;
   gl_Position = pMatrix *vMatrix * vec4(p, 1.0);
   gl_PointSize = 50.0 / pow(gl_Position.w, 2.0);
   vec3 col = hsv2rgb(vec3(hash(vertexId * 567.123), 0.5, 0.8));
   v_color = vec4(col, 1.0);
}

