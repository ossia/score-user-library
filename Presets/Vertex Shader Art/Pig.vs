/*{
  "DESCRIPTION": "Pig",
  "CREDIT": "gaz (ported from https://www.vertexshaderart.com/art/DSH7PskktA2rGgZ6F)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 83549,
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
    "ORIGINAL_VIEWS": 456,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1458742759209
    }
  }
}*/

mat2 rotate(float a) {
    float s=sin(a),c=cos(a);
    return mat2(c,s,-s,c);
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

vec2 meshUV(in float id, in vec2 dim){
    float quadID = floor(id / 6.0);
    vec2 pos = vec2(mod(quadID,dim.x), mod(floor(quadID / dim.x),dim.y));
    float pointID = abs(3.0 - mod(id, 6.0));
    vec2 uv;
    if (fract((pos.x+pos.y)*0.5)<0.1){
        uv = vec2(1.0-floor(pointID / 2.0),mod(pointID, 2.0));
    } else {
        uv = vec2(mod(pointID, 2.0), floor(pointID / 2.0));
    }
    uv += pos;
    uv /= dim;
    return uv;
}

vec3 meshSqhere(in float id, in float split) {
  if (true) {
    // ８面体ベースのMesh
    float d = split * 2.0;
    float n = floor(id / 6.0);
    vec2 q = vec2(mod(n,d), mod(floor(n/d),d));
    vec2 a = q+0.5-split;
    float s = sign(a.x*a.y);
    float c = abs(3.0 - mod(id, 6.0));
    vec2 uv = vec2(mod(c, 2.0), abs(step(0.0, s)-floor(c / 2.0)));
    uv = (uv+q)/split -1.0;
    if ( uv.x > abs(uv.y)) uv.y -= (uv.x - abs(uv.y))*s;
    if (-uv.x > abs(uv.y)) uv.y -= (uv.x + abs(uv.y))*s;
    if ( uv.y > abs(uv.x)) uv.x -= (uv.y - abs(uv.x))*s;
    if (-uv.y > abs(uv.x)) uv.x -= (uv.y + abs(uv.x))*s;
    return normalize(vec3(uv , 0.8*(1.0-pow(max(abs(uv.x),abs(uv.y)),2.0)) *s));
  }
  else
  {
    // 平面Meshの２枚使い
 vec2 dim = vec2(split);
 vec2 uv = meshUV(mod(id, 6.0*dim.x*dim.y), dim);
    vec3 p = vec3(uv * 2.0 - 1.0 , 0.0);
    p.z = 0.85*(1.0- pow(max(abs(p.x),abs(p.y)),2.0));
    p.xz *= sign(floor(id/(6.0*dim.x*dim.y))-0.5);
    return normalize(p);
  }
}

vec3 boss(in vec3 p){
    vec3 ret = vec3(0.0);
    ret.y += -0.3 * smoothstep(0.2,0.0, length(abs(p.zx)-vec2(0.4,0.4)))*step(0.0,-p.y);
    ret.y += 0.2 * smoothstep(0.15,0.0, length(abs(p.zx-vec2(0.4,0.0))-vec2(0.0, 0.4)))*step(0.0, p.y);
    ret.z += 0.15 * smoothstep(0.4, 0.3, length(p.yx)) * step(0.0, p.z);
    ret.z += -0.15 * smoothstep(0.1, 0.0, length(abs(p.yx) - vec2(0.0, 0.15)))*step(0.0, p.z);
    ret.z += -0.1 * smoothstep(0.1, 0.0, length(abs(p.yx-vec2(0.4,0.0))-vec2(0.0,0.3)))*step(0.0, p.z);
    ret.z += -0.15 * smoothstep( 0.1, 0.0, length(p.yx - vec2(0.35,0.0))) * step(0.0, -p.z);
    return ret;
}

float map(in vec3 p) // distance function
{
    p -= boss(p);
    return (length(p) - 1.0);
}

vec3 calcNormal(in vec3 p)
{
    vec2 e = vec2(1.0,-1.0)*0.002;
    return normalize(
        e.xyy*map(p+e.xyy)+e.yyx*map(p+e.yyx)+
        e.yxy*map(p+e.yxy)+e.xxx*map(p+e.xxx));
}

void main() {

  mat4 pMatrix = perspective(45.0, resolution.x/resolution.y, 0.1, 100.0);
  mat4 vMatrix = mat4(1.0);
  vMatrix[3].z = -3.5;
  float split = floor(sqrt(floor(vertexCount/6.0)));
  split = floor(split/2.0);
  vec3 p = meshSqhere(vertexId, split);
  p += boss(p);
  vec3 nor = calcNormal(p);
  vec3 col = vec3(0.8,0.5,0.3);
  vec3 li = normalize(vec3(0.5,1.0,1.0));
  float dif = clamp(dot(nor,li),0.0,1.0);
  float amb = max(0.5+0.5*nor.y,0.0);
  col *= clamp(max(dif,0.3)*amb,0.0,1.0);
  p.zx *= rotate(time*0.5);
  gl_Position = pMatrix *vMatrix * vec4(p, 1.0);
  v_color = vec4(col, 1.0);
}