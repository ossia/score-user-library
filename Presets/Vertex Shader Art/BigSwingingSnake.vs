/*{
  "DESCRIPTION": "BigSwingingSnake",
  "CREDIT": "zug (ported from https://www.vertexshaderart.com/art/6bpRiTn7zbJ2Birz8)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
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
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1522119400992
    }
  }
}*/

//KDrawmode=GL_LINE_STRIP
#define PI 3.141594
#define FIT_VERTICAL
#define KP1 3.//KParameter 0.>>10.
vec3 computeVert(float angle, float H) {
  float STEP = (time*0.7*smoothstep(0.1,KP1,1.),KP1);
  float R = (cos(H * 2.6 + STEP * 2.5 + sin(STEP * 14.3 + H * 3.0) * (cos(STEP * 0.6) + 0.6)) * 0.2 + 0.9) * (cos(STEP * 0.5 + H * 1.4) * 0.3 + 0.9);
  R *= sin((H + 4.0) * 0.175);

  float Q = cos(STEP * 0.54 + H * 0.7);
  float dX = cos(H * 1.4) * Q * 1.5;
  float dY = sin(H * 0.75) * Q * 0.4;
  float dZ = sin(H * 0.5) * Q * 0.15;
  return vec3(cos(angle) * R, H, sin(angle) * R) + vec3(dX, dY, dZ);
}

vec3 computeNorm(float angle, float H) {
  float dA = 0.01;
  float dH = 0.1;
  vec3 A = computeVert(angle, H *2.);
  vec3 B = computeVert(angle + dA, H);
  vec3 C = computeVert(angle, H + dH);
  return normalize(-cross((B-A)/dA,(C-A)/dH));
}

void main() {
  int NUM_ROT =76;
  float dH = 0.05;

  float STEP = time*0.7;

  int base = int(vertexId) /5;
  int level = int(base) / NUM_ROT;
  int idx = int(mod(vertexId,8.0*sin(time*min(mouse.x+1.5,3.))));
  vec3 xyz = vec3(0,0,0);
  vec3 N = normalize(vec3(1,0,0));

  float dA = 2.0 * PI / float(NUM_ROT);

  float H = float(level) * dH - 5.0;
  float angle = float(base) * dA;

  if (idx == 0) {
   xyz = computeVert(angle, H);
   N = computeNorm(angle, H);
  }
  if (idx == 1) {
   xyz = computeVert(angle + dA, H);
   N = computeNorm(angle + dA, H);
  }
  if (idx == 2) {
   xyz = computeVert(angle + dA, H + dH);
   N = computeNorm(angle + dA, H + dH);
  }

  if (idx == 3) {
   xyz = computeVert(angle + dA, H + dH);
   N = computeNorm(angle + dA, H + dH);
  }
  if (idx == 4) {
   xyz = computeVert(angle, H + dH);
   N = computeNorm(angle, H * dH);
  }
  if (idx == 5) {
   xyz = computeVert(angle, H);
   N = computeNorm(angle, H);
  }

  #ifdef FIT_VERTICAL
    vec2 aspect = vec2(resolution.y *2. / resolution.x, (1.+mouse.y*2.));
  #else
    vec2 aspect = vec2((1.+mouse.x*2.), resolution.x / resolution.y);
  #endif

  float Cs = cos(STEP);
  float Si = sin(STEP);
  mat3 rot = mat3(vec3(Cs,0,Si), vec3(0,1,0), vec3(-Si,0,Cs));
  mat3 rot2 = mat3(vec3(0,1,0), vec3(Cs,0,Si), vec3(-Si,0,Cs));
  xyz *= 0.23;
  xyz *= rot;
  N *= rot;
  gl_Position = vec4(xyz.xy * aspect / (3.0 + xyz.z), xyz.z, 1);

  vec3 light = normalize(vec3(1,1,-1));
  vec3 V = vec3(0,0,1);
  float A = 0.8 + cos(xyz.y * 0.6 / STEP);
  float D = 0.6 * clamp(dot(N, light), 0.0, 1.0);
  float S = 1.6 * pow(clamp(dot(light, reflect(V,N)),0.0,1.0), 5.0);
  vec3 A_col = vec3(1,1,1) * N * rot2;
  vec3 D_col = vec3(1,1,1) * N;
  vec3 S_col = vec3(1,1,2);
  vec3 LUM = A * A_col + D * D_col +S * S_col;
  v_color = vec4(LUM, 1);
}