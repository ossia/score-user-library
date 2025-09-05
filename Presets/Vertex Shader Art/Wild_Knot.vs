/*{
  "DESCRIPTION": "Wild Knot",
  "CREDIT": "gaz (ported from https://www.vertexshaderart.com/art/hGb3X2yH769jCbfDy)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 14680,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "CSS",
  "BACKGROUND_COLOR": [
    0.011764705882352941,
    0.3607843137254902,
    0.47843137254901963,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 270,
    "ORIGINAL_DATE": {
      "$date": 1453131558231
    }
  }
}*/

// http://jsdo.it/gaziya/zQos

#define PI 3.14159265359
#define PI2 ( PI * 2.0 )

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

//https://www.shadertoy.com/view/ltXGW2
vec3 gc1,gs1,gc2,gs2,gc3,gs3;
float freq2;
//knot's from dr2 @ https://www.shadertoy.com/view/4ts3zl
void InitCurve(float tm){
 float t=1.0+sin(tm);
 freq2=mix(2.0,5.0,clamp(t-1.0,0.0,1.0));
 gc1 = mix(vec3 ( 41, 36, 0), mix(vec3 ( 32, 94, 16),vec3 ( -22, 11, 0),clamp(t-1.0,0.0,1.0)),clamp(t,0.0,1.0));
 gs1 = mix(vec3 (-18, 27, 45),mix(vec3 ( -51, 41, 73),vec3 (-128, 0, 0),clamp(t-1.0,0.0,1.0)),clamp(t,0.0,1.0));
 gc2 = mix(vec3 (-83, -113, -30),mix(vec3 (-104, 113, -211),vec3 ( 0, 34, 8),clamp(t-1.0,0.0,1.0)),clamp(t,0.0,1.0));
 gs2 = mix(vec3 (-83, 30, 113),mix(vec3 ( -34, 0, -39),vec3 ( 0, -39, -9),clamp(t-1.0,0.0,1.0)),clamp(t,0.0,1.0));
 gc3 = mix(vec3 (-11, 11, -11),mix(vec3 ( 104, -68, -99),vec3 ( -44, -43, 70),clamp(t-1.0,0.0,1.0)),clamp(t,0.0,1.0));
 gs3 = mix(vec3 ( 27, -27, 27),mix(vec3 ( -91, -124, -21),vec3 ( -78, 0, -40),clamp(t-1.0,0.0,1.0)),clamp(t,0.0,1.0));
}
vec3 F (float a) //dr2's knots
{
 return (gc1 * cos (a) + gs1 * sin (a) +
  gc2 * cos (freq2 * a) + gs2 * sin (freq2 * a) +
  gc3 * cos (3. * a) + gs3 * sin (3. * a))*0.01;
}
/////////

vec3 func(in float a) {
    InitCurve(time);
    return F(a * PI2);
}

vec4 quaternion(in vec3 axis, in float theta) {
    return vec4(axis * sin(theta / 2.0), cos(theta / 2.0));
}

vec3 qTransform(in vec4 q, in vec3 v) {
    return v + 2.0 * cross(cross(v, q.xyz) - q.w * v, q.xyz);
}

vec3 map(in vec2 uv) {
    const float r = 0.15;
    vec3 coord = func(uv.y);
    vec3 delta = normalize(func(uv.y + 0.01) - func(uv.y - 0.01));
    vec4 q = quaternion(delta, uv.x * PI2);
    vec3 p = normalize(cross(
        func(uv.y + 0.01) - coord,
        func(uv.y - 0.01) - coord
        )) * r;
    return coord + qTransform(q, p);
}

vec3 normal(in vec2 p) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(cross(
        map(p + e) - map(p - e),
        map(p + e.yx) - map(p - e.yx)
    ));
}

mat4 perspective(in float fovy, in float aspect, in float near, in float far)
{
    float top = near * tan(fovy * PI / 360.0);
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

mat2 rotate(in float a) {
 return mat2(cos(a), sin(a), -sin(a), cos(a));
}

void main() {
    float a = floor(vertexId / 6.0);
    float b = abs(3.0 - mod(vertexId, 6.0));
   float polyCount = vertexCount/6.0;
   vec2 dim = floor(vec2(sqrt(polyCount/8.0), sqrt(polyCount*8.0)));
   //vec2 dim = vec2(32, 256); //vertexCount = 49152
    vec2 p = vec2(mod(a, dim.x), floor(a / dim.x));
    vec2 offset = vec2(mod(b, 2.0), floor(b / 2.0));
    vec2 uv = (p + offset) / dim;
    vec3 pos = map(uv);
    vec3 nor = normal(uv);
    float t = time * 1.2;
    pos.xz *= rotate(t);
    nor.xz *= rotate(t);
    mat4 vMatrix = mat4(1.0);
    vMatrix[3].z = -8.0;
   mat4 pMatrix = perspective(45.0, resolution.x / resolution.y, 0.1, 100.0);
    gl_Position = pMatrix * vMatrix * vec4(pos, 1.0);
    vec3 light = normalize(vec3(0.2, 0.3, 1.0));
   vec3 col = hsv2rgb(vec3(time * 0.03, 0.8, 1.0));
   col *= max(dot(light, nor), 0.2);
    col += pow(max(dot(vec3(0, 0, 1), reflect(-light, nor)), 0.0), 50.0);
    col = pow(col, vec3(0.8));
   v_color = vec4(col,1.0);
}
