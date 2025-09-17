/*{
  "DESCRIPTION": "ShaderDough - conversion from tdhooper shader\nhttps://www.shadertoy.com/view/4tc3WB",
  "CREDIT": "aiekick (ported from https://www.vertexshaderart.com/art/oJEAooRzirpb8qcPe)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Geometry",
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.14901960784313725,
    0.0392156862745098,
    0.21176470588235294,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1241,
    "ORIGINAL_LIKES": 4,
    "ORIGINAL_DATE": {
      "$date": 1535737942011
    }
  }
}*/

/////////////////////////////////////////////////////////////////////
/// https://github.com/glslify/glsl-inverse/blob/master/index.glsl //
/////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////
//// ShaderDough from @tdhooper in
//// https://www.shadertoy.com/view/4tc3WB
//////////////////////////////////////////////
// Disable to see more colour variety
#define SEAMLESS_LOOP
//#define COLOUR_CYCLE
#define PI 3.14159265359
#define PHI (1.618033988749895)
float t;
#define saturate(x) clamp(x, 0., 1.)
// --------------------------------------------------------
// http://www.neilmendoza.com/glsl-rotation-about-an-arbitrary-axis/
// --------------------------------------------------------
mat3 rotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat3(
        oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s,
        oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s,
        oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c
    );
}
// --------------------------------------------------------
// http://math.stackexchange.com/a/897677
// --------------------------------------------------------
mat3 orientMatrix(vec3 A, vec3 B) {
    mat3 Fi = mat3(
        A,
        (B - dot(A, B) * A) / length(B - dot(A, B) * A),
        cross(B, A)
    );
    mat3 G = mat3(
        dot(A, B), -length(cross(A, B)), 0,
        length(cross(A, B)), dot(A, B), 0,
        0, 0, 1
    );
    return Fi * G * inverse(Fi);
}
// --------------------------------------------------------
// HG_SDF
// https://www.shadertoy.com/view/Xs3GRB
// --------------------------------------------------------
#define GDFVector3 normalize(vec3(1, 1, 1 ))
#define GDFVector3b normalize(vec3(-1, -1, -1 ))
#define GDFVector4 normalize(vec3(-1, 1, 1))
#define GDFVector4b normalize(vec3(-1, -1, 1))
#define GDFVector5 normalize(vec3(1, -1, 1))
#define GDFVector5b normalize(vec3(1, -1, -1))
#define GDFVector6 normalize(vec3(1, 1, -1))
#define GDFVector6b normalize(vec3(-1, 1, -1))
#define GDFVector7 normalize(vec3(0, 1, PHI+1.))
#define GDFVector7b normalize(vec3(0, 1, -PHI-1.))
#define GDFVector8 normalize(vec3(0, -1, PHI+1.))
#define GDFVector8b normalize(vec3(0, -1, -PHI-1.))
#define GDFVector9 normalize(vec3(PHI+1., 0, 1))
#define GDFVector9b normalize(vec3(PHI+1., 0, -1))
#define GDFVector10 normalize(vec3(-PHI-1., 0, 1))
#define GDFVector10b normalize(vec3(-PHI-1., 0, -1))
#define GDFVector11 normalize(vec3(1, PHI+1., 0))
#define GDFVector11b normalize(vec3(1, -PHI-1., 0))
#define GDFVector12 normalize(vec3(-1, PHI+1., 0))
#define GDFVector12b normalize(vec3(-1, -PHI-1., 0))
#define GDFVector13 normalize(vec3(0, PHI, 1))
#define GDFVector13b normalize(vec3(0, PHI, -1))
#define GDFVector14 normalize(vec3(0, -PHI, 1))
#define GDFVector14b normalize(vec3(0, -PHI, -1))
#define GDFVector15 normalize(vec3(1, 0, PHI))
#define GDFVector15b normalize(vec3(1, 0, -PHI))
#define GDFVector16 normalize(vec3(-1, 0, PHI))
#define GDFVector16b normalize(vec3(-1, 0, -PHI))
#define GDFVector17 normalize(vec3(PHI, 1, 0))
#define GDFVector17b normalize(vec3(PHI, -1, 0))
#define GDFVector18 normalize(vec3(-PHI, 1, 0))
#define GDFVector18b normalize(vec3(-PHI, -1, 0))
#define fGDFBegin float d = 0.;
// Version with variable exponent.
// This is slow and does not produce correct distances, but allows for bulging of objects.
#define fGDFExp(v) d += pow(abs(dot(p, v)), e);
// Version with without exponent, creates objects with sharp edges and flat faces
#define fGDF(v) d = max(d, abs(dot(p, v)));
#define fGDFExpEnd return pow(d, 1./e) - r;
#define fGDFEnd return d - r;
// Primitives follow:
float fDodecahedron(vec3 p, float r) {
    fGDFBegin
    fGDF(GDFVector13) fGDF(GDFVector14) fGDF(GDFVector15) fGDF(GDFVector16)
    fGDF(GDFVector17) fGDF(GDFVector18)
    fGDFEnd
}
float fIcosahedron(vec3 p, float r) {
    fGDFBegin
    fGDF(GDFVector3) fGDF(GDFVector4) fGDF(GDFVector5) fGDF(GDFVector6)
    fGDF(GDFVector7) fGDF(GDFVector8) fGDF(GDFVector9) fGDF(GDFVector10)
    fGDF(GDFVector11) fGDF(GDFVector12)
    fGDFEnd
}
float vmax(vec3 v) {
    return max(max(v.x, v.y), v.z);
}
float sgn(float x) {
 return (x<0.)?-1.:1.;
}
// Plane with normal n (n is normalized) at some distance from the origin
float fPlane(vec3 p, vec3 n, float distanceFromOrigin) {
    return dot(p, n) + distanceFromOrigin;
}

// Box: correct distance to corners
float fBox(vec3 p, vec3 b) {
 vec3 d = abs(p) - b;
 return length(max(d, vec3(0))) + vmax(min(d, vec3(0)));
}
// Distance to line segment between <a> and <b>, used for fCapsule() version 2below
float fLineSegment(vec3 p, vec3 a, vec3 b) {
 vec3 ab = b - a;
 float t = saturate(dot(p - a, ab) / dot(ab, ab));
 return length((ab*t + a) - p);
}
// Capsule version 2: between two end points <a> and <b> with radius r
float fCapsule(vec3 p, vec3 a, vec3 b, float r) {
 return fLineSegment(p, a, b) - r;
}
// Rotate around a coordinate axis (i.e. in a plane perpendicular to that axis) by angle <a>.
// Read like this: R(p.xz, a) rotates "x towards z".
// This is fast if <a> is a compile-time constant and slower (but still practical) if not.
void pR(inout vec2 p, float a) {
    p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}
// Reflect space at a plane
float pReflect(inout vec3 p, vec3 planeNormal, float offset) {
    float t = dot(p, planeNormal)+offset;
    if (t < 0.) {
        p = p - (2.*t)*planeNormal;
    }
    return sign(t);
}
// Repeat around the origin by a fixed angle.
// For easier use, num of repetitions is use to specify the angle.
float pModPolar(inout vec2 p, float repetitions) {
 float angle = 2.*PI/repetitions;
 float a = atan(p.y, p.x) + angle/2.;
 float r = length(p);
 float c = floor(a/angle);
 a = mod(a,angle) - angle/2.;
 p = vec2(cos(a), sin(a))*r;
 // For an odd number of repetitions, fix cell index of the cell in -x direction
 // (cell index would be e.g. -5 and 5 in the two halves of the cell):
 if (abs(c) >= (repetitions/2.)) c = abs(c);
 return c;
}
// Repeat around an axis
void pModPolar(inout vec3 p, vec3 axis, float repetitions, float offset) {
    vec3 z = vec3(0,0,1);
 mat3 m = orientMatrix(axis, z);
    p *= inverse(m);
    pR(p.xy, offset);
    pModPolar(p.xy, repetitions);
    pR(p.xy, -offset);
    p *= m;
}
// --------------------------------------------------------
// knighty
// https://www.shadertoy.com/view/MsKGzw
// --------------------------------------------------------
int Type=5;
vec3 nc;
vec3 pbc;
vec3 pca;
void initIcosahedron() {//setup folding planes and vertex
    float cospin=cos(PI/float(Type)), scospin=sqrt(0.75-cospin*cospin);
    nc=vec3(-0.5,-cospin,scospin);//3rd folding plane. The two others are xz and yz planes
 pbc=vec3(scospin,0.,0.5);//No normalization in order to have 'barycentric' coordinates work evenly
 pca=vec3(0.,scospin,cospin);
 pbc=normalize(pbc); pca=normalize(pca);//for slightly better DE. In reality it's not necesary to apply normalization :)

}
void pModIcosahedron(inout vec3 p) {
    p = abs(p);
    pReflect(p, nc, 0.);
    p.xy = abs(p.xy);
    pReflect(p, nc, 0.);
    p.xy = abs(p.xy);
    pReflect(p, nc, 0.);
}
float indexSgn(float s) {
 return s / 2. + 0.5;
}
bool boolSgn(float s) {
 return bool(s / 2. + 0.5);
}
float pModIcosahedronIndexed(inout vec3 p, int subdivisions) {
 float x = indexSgn(sgn(p.x));
 float y = indexSgn(sgn(p.y));
 float z = indexSgn(sgn(p.z));
    p = abs(p);
 pReflect(p, nc, 0.);

 float xai = sgn(p.x);
 float yai = sgn(p.y);
    p.xy = abs(p.xy);
 float sideBB = pReflect(p, nc, 0.);

 float ybi = sgn(p.y);
 float xbi = sgn(p.x);
    p.xy = abs(p.xy);
 pReflect(p, nc, 0.);

    float idx = 0.;

    float faceGroupAi = indexSgn(ybi * yai * -1.);
    float faceGroupBi = indexSgn(yai);
    float faceGroupCi = clamp((xai - ybi -1.), 0., 1.);
    float faceGroupDi = clamp(1. - faceGroupAi - faceGroupBi - faceGroupCi, 0., 1.);

    idx += faceGroupAi * (x + (2. * y) + (4. * z));
    idx += faceGroupBi * (8. + y + (2. * z));
    # ifndef SEAMLESS_LOOP
     idx += faceGroupCi * (12. + x + (2. * z));
    # endif
    idx += faceGroupDi * (12. + x + (2. * y));

 return idx;
}
// --------------------------------------------------------
// IQ
// https://www.shadertoy.com/view/ll2GD3
// --------------------------------------------------------
vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) {
    return a + b*cos( 6.28318*(c*t+d) );
}

vec3 spectrum(float n) {
    return pal( n, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.33,0.67) );
}
// --------------------------------------------------------
// tdhooper
// https://www.shadertoy.com/view/Mtc3RX
// --------------------------------------------------------
vec3 vMin(vec3 p, vec3 a, vec3 b, vec3 c) {
    float la = length(p - a);
    float lb = length(p - b);
    float lc = length(p - c);
    if (la < lb) {
        if (la < lc) {
        return a;
        } else {
        return c;
        }
    } else {
        if (lb < lc) {
        return b;
        } else {
        return c;
        }
    }
}
vec3 icosahedronVertex(vec3 p) {
    if (p.z > 0.) {
        if (p.x > 0.) {
        if (p.y > 0.) {
        return vMin(p, GDFVector13, GDFVector15, GDFVector17);
        } else {
        return vMin(p, GDFVector14, GDFVector15, GDFVector17b);
        }
        } else {
        if (p.y > 0.) {
        return vMin(p, GDFVector13, GDFVector16, GDFVector18);
        } else {
        return vMin(p, GDFVector14, GDFVector16, GDFVector18b);
        }
        }
    } else {
        if (p.x > 0.) {
        if (p.y > 0.) {
        return vMin(p, GDFVector13b, GDFVector15b, GDFVector17);
        } else {
        return vMin(p, GDFVector14b, GDFVector15b, GDFVector17b);
        }
        } else {
        if (p.y > 0.) {
        return vMin(p, GDFVector13b, GDFVector16b, GDFVector18);
        } else {
        return vMin(p, GDFVector14b, GDFVector16b, GDFVector18b);
        }
        }
    }
}
vec4 icosahedronAxisDistance(vec3 p) {
    vec3 iv = icosahedronVertex(p);
    vec3 originalIv = iv;

    vec3 pn = normalize(p);
    pModIcosahedron(pn);
    pModIcosahedron(iv);

    float boundryDist = dot(pn, vec3(1, 0, 0));
    float boundryMax = dot(iv, vec3(1, 0, 0));
    boundryDist /= boundryMax;

    float roundDist = length(iv - pn);
    float roundMax = length(iv - vec3(0, 0, 1.));
    roundDist /= roundMax;
    roundDist = -roundDist + 1.;

    float blend = 1. - boundryDist;
 blend = pow(blend, 6.);

    float dist = mix(roundDist, boundryDist, blend);

    return vec4(originalIv, dist);
}
void pTwistIcosahedron(inout vec3 p, float amount) {
    vec4 a = icosahedronAxisDistance(p);
    vec3 axis = a.xyz;
    float dist = a.a;
    mat3 m = rotationMatrix(axis, dist * amount);
    p *= m;
}
struct Model {
    float dist;
    vec3 colour;
    float id;
};
Model fInflatedIcosahedron(vec3 p, vec3 axis) {
    float d = 1000.;

    # ifdef SEAMLESS_LOOP
     // Radially repeat along the rotation axis, so the
     // colours repeat more frequently and we can use
     // less frames for a seamless loop
     pModPolar(p, axis, 3., PI/2.);
 # endif

    // Slightly inflated icosahedron
    float idx = pModIcosahedronIndexed(p, 0);
    d = min(d, dot(p, pca) - .9);
    d = mix(d, length(p) - .9, .5);

    // Colour each icosahedron face differently
    # ifdef SEAMLESS_LOOP
     if (idx == 3.) {
      idx = 2.;
     }
     idx /= 10.;
    # else
     idx /= 20.;
    # endif
    # ifdef COLOUR_CYCLE
     idx = mod(idx + t*1.75, 1.);
    # endif
    vec3 colour = floor(spectrum(idx) * 6.) / 6. ;

    d *= .6;
 return Model(d, colour, 1.);
}
void pTwistIcosahedron(inout vec3 p, vec3 center, float amount) {
    p += center;
    pTwistIcosahedron(p, 5.5);
    p -= center;
}
Model model(vec3 p) {
    float rate = PI/6.;
    vec3 axis = pca;

    vec3 twistCenter = vec3(0);
    twistCenter.x = cos(t * rate * -3.) * .3;
 twistCenter.y = sin(t * rate * -3.) * .3;

 mat3 m = rotationMatrix(
        reflect(axis, vec3(0,1,0)),
        t * -rate
    );
    p *= m;
    twistCenter *= m;

    pTwistIcosahedron(p, twistCenter, 5.5);

 return fInflatedIcosahedron(p, axis);
}
// The MINIMIZED version of https://www.shadertoy.com/view/Xl2XWt
const float MAX_TRACE_DISTANCE = 30.0; // max trace distance
const float INTERSECTION_PRECISION = 0.001; // precision of the intersection
const int NUM_OF_TRACE_STEPS = 100;
vec2 opU( vec2 d1, vec2 d2 ){
    return (d1.x<d2.x) ? d1 : d2;
}
Model map( vec3 p )
{
    return model(p*2.);
}
//////////////////////////////////////////////
//////////////////////////////////////////////
//////////////////////////////////////////////

//////////////////////////////////////////////
//https://www.vertexshaderart.com/art/DSH7PskktA2rGgZ6F
//////////////////////////////////////////////

vec3 meshSqhere(in float id)
{
    float split = floor(sqrt(floor(vertexCount/6.0)));
 split = floor(split/2.0);
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

//////////////////////////////////////////////
//////////////////////////////////////////////
//////////////////////////////////////////////

vec3 getPoint(float vId)
{
 vec3 p = meshSqhere(vertexId);

 float d = 0.;
 vec3 rd = normalize(p);
 vec3 ro = rd * -3.;
 for (int i=0;i<5;i++)
 {
  d += map(ro + rd * d).dist;
 }

 return ro + rd * d;
}

vec3 getNormal( vec3 p, float prec )
{
    vec2 e = vec2( prec, 0. );
    vec3 n = vec3(
        map(p+e.xyy).dist - map(p-e.xyy).dist,
        map(p+e.yxy).dist - map(p-e.yxy).dist,
        map(p+e.yyx).dist - map(p-e.yyx).dist );
    return normalize(n);
}

void main()
{
 initIcosahedron();
    t = time * 0.8;
   //t = 0.;

    vec3 p = getPoint(vertexId);

   vec3 ro = vec3(0,0,-3.);
    float d = length(ro-p);

   gl_PointSize = 3.;//8.-d;

 vec3 rd = vec3(0,0,-1.);
 vec3 ld = normalize(vec3(1.,0,-1.));
 vec3 n = getNormal(p, 0.0001);
 float sd = map(p + n).dist;

 float diff = max(dot(n, ld), 0.);
    float spec = pow(max(dot( reflect(-ld, n), rd), 0.), 2.);
 vec3 col = map(p).colour * 0.8 + diff * 0.2 + spec * 0.8;
   col /= sd;

   float screenZ = -0.;
 float eyeZ = -4.5;
 p.xy *= (eyeZ - screenZ) / (p.z - eyeZ);
 p.x /= resolution.x / resolution.y;

 gl_Position = vec4(p, 1);

   //v_color = vec4(0.);
    //if (p.z < 0.)
   v_color = vec4(clamp(col,0.,1.), 1);
}
// Removed built-in GLSL functions: inverse