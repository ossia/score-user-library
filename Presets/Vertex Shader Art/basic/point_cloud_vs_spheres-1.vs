/*{
  "DESCRIPTION": "point cloud vs spheres",
  "CREDIT": "kessondalef (ported from https://www.vertexshaderart.com/art/4FQ77YanjkTRoSWip)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles",
    "Nature"
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
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 11,
    "ORIGINAL_DATE": {
      "$date": 1548100689101
    }
  }
}*/

// 2D Random
float random (in vec2 st) {
    return fract(sin(dot(st.xy,
        vec2(12.9898,78.233)))
        * 43758.5453123);
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve. Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
        (c - a)* u.y * (1.0 - u.x) +
        (d - b) * u.x * u.y;
}

mat4 rotateX(float angle) {
  float s = sin(angle);
  float c = cos(angle);

  return mat4(
    1, 0, 0, 0,
    0, c, s, 0,
    0, -s, c, 0,
    0, 0, 0, 1);
}

mat4 rotateY(float angle) {
    float s = sin(angle);
    float c = cos(angle);

    return mat4(
      c, 0,-s, 0,
      0, 1, 0, 0,
      s, 0, c, 0,
      0, 0, 0, 1);
}

mat4 rotateZ(float angle) {
    float s = sin(angle);
    float c = cos(angle);

    return mat4(
      c,-s, 0, 0,
      s, c, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1);
}

vec3 posf2(float t, float i) {
 return vec3(
      //sin(t+i*.9553) +
      //sin(t*0.0311+i) +
      cos(t*.4+i*1.53) +
      sin(t*1.84+i*.76) +
      noise(vec2(t, i)),
      //sin(t+i*.79553+2.1) +
      //sin(t*1.311+i*1.1311+2.1) +
      cos(t*1.4+i*1.353-2.1) +
      sin(t*1.84+i*.476-2.1) +
      noise(vec2(t*.3, i)),
      //sin(t+i*.5553-2.1) +
      //sin(t*1.311+i*1.1-2.1) +
      //cos(t*1.4+i*1.23+2.1) +
      sin(t*1.84+i*.36+2.1)// +
      //noise(vec2(t, i*))
 )*.2;
}

vec3 posf0(float t) {
  return posf2(t,-1.)*.5;
}

vec3 posf(float t, float i) {
  return posf2(t*.03,i) + posf0(t);
}

vec3 push(float t, float i, vec3 ofs, float lerpEnd) {
  vec3 pos = posf(t,i)+ofs;

  vec3 posf = fract(pos+.5)-.5;

  float l = length(posf)*2.;
  return (- posf + posf/l)*(1.-smoothstep(lerpEnd,1.,l));
}

void main() {
  // more or less random movement
  float t = time*.1;
  float i = vertexId+sin(vertexId)*100.;

  vec3 pos = posf(t,i);
  vec3 ofs = vec3(0);
  for (float f = -10.; f < 0.; f++) {
   ofs += push(t+f*.05,i,ofs,2.-exp(-f*.1));
  }
  ofs += push(t,i,ofs,.999);

  pos -= posf0(t);

  pos += ofs;

  pos.yz *= mat2(.8,.6,-.6,.8);
  pos.xz *= mat2(.8,.6,-.6,.8);

  pos.x *= resolution.y/resolution.x;
  pos.z *= resolution.y/resolution.x;

  mat4 rotation = rotateY(time*0.1);
  vec4 rot = vec4(pos.xyz, 1.0) * rotation;

  pos.z += .5;

  rot *= 2.0;

  //pos.xy *= .6/pos.z;

  //gl_Position = vec4(pos.x, pos.y*resolution.x/resolution.y, pos.z*.1, 1);
  gl_Position = vec4(rot.xyz, 1);
  gl_PointSize = 1.;

  v_color = vec4(1.0, 1.0, 1.0, 1.0);
}