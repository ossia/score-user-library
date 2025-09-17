/*{
  "DESCRIPTION": "\u30af\u30e9\u30b2",
  "CREDIT": "gaz (ported from https://www.vertexshaderart.com/art/bN3QdqY39pxGw8csG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 32665,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.592156862745098,
    0.5764705882352941,
    0.49019607843137253,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 248,
    "ORIGINAL_DATE": {
      "$date": 1458951994831
    }
  }
}*/

vec3 hsv(in float h, in float s, in float v) {
    return mix(vec3(1.0), clamp((abs(fract(
        h + vec3(3.0, 2.0, 1.0) / 3.0) * 6.0 - 3.0) - 1.0), 0.0, 1.0), s) * v;
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

mat2 rotate(float a) {
    float s=sin(a),c=cos(a);
    return mat2(c,s,-s,c);
}

vec2 meshUV(in float id, in vec2 dim){
   float quadId = floor(id / 10.0);
   float pointId = mod(id,10.0);

   vec2 pos = vec2(mod(quadId,dim.x),(floor(quadId / dim.x)));
   vec2 p1 = vec2(0,0);
   vec2 p2 = vec2(1,0);
   vec2 p3 = vec2(0,1);
   vec2 p4 = vec2(1,1);
   vec2 uv;

   if (pointId==0.0) uv = p1;
   if (pointId==1.0) uv = p2;
   if (pointId==2.0) uv = p1;
   if (pointId==3.0) uv = p3;
   if (mod(pos.x+pos.y,2.0)<0.5){
    if (pointId==4.0) uv = p2;
    if (pointId==5.0) uv = p3;
   } else {
    if (pointId==4.0) uv = p1;
    if (pointId==5.0) uv = p4;
   }
   if (pointId==6.0) uv = p4;
   if (pointId==7.0) uv = p2;
   if (pointId==8.0) uv = p4;
   if (pointId==9.0) uv = p3;
    uv += pos;
    uv /= dim;
    return uv;
}

void main() {
 mat4 pMatrix = perspective(45.0, resolution.x/resolution.y, 0.1, 100.0);
   mat4 vMatrix = mat4(1.0);
   vMatrix[3].z = -3.5;

    vec2 dim = vec2(10);
    float num = 10.0*dim.x*dim.y;
    float polyId = floor(vertexId/num);
    float pointId = mod(vertexId, num);
    vec3 p = vec3(0);
    vec2 uv = meshUV(pointId, dim);
    p.xy = uv*2.0-1.0;
    vec3 p1 = p;
    p.z = 0.85*(1.0- pow(max(abs(p.x),abs(p.y)),2.0));
    p = normalize(p);
   p = mix(p1,p, 0.7*(smoothstep(0.0,1.0,abs(fract(time*0.2+hash(polyId + 46.12))*2.0-1.0)))+0.3);
 p *= 0.35;
    p.xy *= rotate(time*0.3*hash(polyId + 46.12)+hash(polyId + 78.12));
    p.yz *= rotate(time*0.5*hash(polyId + 37.12)+hash(polyId + 56.12));
    vec3 offset = hash31(polyId * 12.12 + 34.34) * 2.0 - 1.0;
    vec3 v = hash31(polyId * 56.56 + 78.78) * 2.0 - 1.0;
   offset = abs(fract(offset + v * time * 0.03) * 2.0 - 1.0) * 2.0 - 1.0;
    p += offset*2.5;
   gl_Position = pMatrix *vMatrix * vec4(p, 1.0);
   vec3 col = hsv(hash(polyId * 567.123), 0.5, 0.3);
   v_color = vec4(col, 1.0);
}

