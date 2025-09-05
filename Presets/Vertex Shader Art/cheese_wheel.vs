/*{
  "DESCRIPTION": "cheese wheel - first go at this stuff",
  "CREDIT": "blackle (ported from https://www.vertexshaderart.com/art/SAxr7jfCpJMn2zJyG)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 38763,
  "PRIMITIVE_MODE": "TRIANGLES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.16862745098039217,
    0.16862745098039217,
    0.16862745098039217,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 615,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1617861662855
    }
  }
}*/

#define PI radians(180.)
#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

vec3 posOnSphere(float latid, float longid, float numlat, float numlong) {
  longid = longid/numlong*3.1415*2.-3.1415;
  latid = latid/numlat*3.1415-3.1415/2.;
  return vec3(sin(longid)*cos(latid), sin(latid), cos(longid)*cos(latid));
}

float smin(float a, float b, float k) {
  float h = max(0., k-abs(b-a))/k;
  return min(a,b) - h*h*h*k/6.;
}

vec3 closest(vec3 p) {
  //return normalize(p);
  //return mix(normalize(p), vec3(p.x, sign(p.y)*.5, p.z), step(.5,abs(p.y)));
  p = normalize(p);
  p.y = smin(p.y, .5, .2);
  p.y = -smin(-p.y, .5, .2);
  return p;
}
float dist(vec3 p) {
  //return length(p) - 1.;
  //return length(p-closest(p));
  return -smin(1.-length(p),.5-abs(p.y),.2);
}

vec3 norm(vec3 p) {
  mat3 k = mat3(p,p,p)-mat3(0.001);
  return normalize(dist(p) - vec3(dist(k[0]),dist(k[1]),dist(k[2])));
}

vec3 posForId(float id) {
  float vertid = mod(id, 3.);
  float triid = floor(id/3.);
  float qptid = mod(triid, 2.);
  float quadid = floor(triid/2.);

  float numlat = 80.;
  float numlong = 80.;
  float latid = floor(quadid/numlong) + mix(floor(vertid/2.), 1.-floor(vertid/2.), qptid);
  float longid = mod(quadid,numlong) + mix(mod(vertid,2.), 1.-mod(vertid,2.), qptid);
  vec3 p = posOnSphere(latid, longid, numlat, numlong);
  return closest(p);
}

vec3 erot(vec3 p, vec3 ax, float ro) {
  return mix(dot(p,ax)*ax,p,cos(ro))+sin(ro)*cross(ax,p);
}

void main() {
  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec3 pos = posForId(vertexId);
  vec3 n = norm(pos);
  vec3 on = n;

  vec3 cam = vec3(0,0,1);
  vec3 r = reflect(cam,n);
  n = erot(n, vec3(0,1,0), time);
  n = erot(n, vec3(1,0,0), sin(time/2.)*.3);
  //you need a proper projection matrix blackle...
  //or do I? lmao
  r = erot(r, vec3(0,1,0), time);
  r = erot(r, vec3(1,0,0), sin(time/2.)*.3);
  pos = erot(pos, vec3(0,1,0), time);
  pos = erot(pos, vec3(1,0,0), sin(time/2.)*.3);
  float fres = 1.-abs(dot(n,cam))*.98;

  gl_Position = vec4(pos.xy * aspect, pos.z, 2.);
  gl_PointSize = 10.;

  float spec = length(sin(r*3.)*.5+.5)/sqrt(3.);
  float diff = length(sin(on*2.)*.4+.6)/sqrt(3.);
  //v_color = vec4(n*.5+.5,1);
  v_color = smoothstep(0.,1.,sqrt(vec4(diff*vec3(.9,.5,.3) + pow(spec,8.)*fres, 1)));
}