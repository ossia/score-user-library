/*
{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/NlfGR7 by ChaosOfZen.  Color Ray Marching Example",
    "IMPORTED": {
    },
    "INPUTS": [
    ]
}

*/


//precision highp float;
 
// Constants
#define PI 3.1415925359
#define MAX_STEPS 100// Mar Raymarching steps
#define MAX_DIST 100.// Max Raymarching distance
#define SURF_DIST.01// Surface Distance
 
const vec4 GroundColor = vec4(1.0, 1.0, 1.0, 1.0);
const vec4 OctahedronColor = vec4(1,0,0,1);
const vec4 LinkColor = vec4(0,1,0,1);
const vec4 BoxColor = vec4(0,0,1,1);
 
float colorIntensity = 1.;
vec3 difColor = vec3(1.0, 1.0, 1.0); // Diffuse Color
 
mat2 Rotate(float a) {
    float s=sin(a); 
    float c=cos(a);
    return mat2(c,-s,s,c);
}
 
///////////////////////
// Primitives
///////////////////////
 
// Round Box - exact
float roundBoxSDF(vec3 p,vec3 b,float r) {
    vec3 q=abs(p)-b;
    return length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.)-r;
}
 
// Plane - exact
float planeSDF(vec3 p,vec4 n) {
    // n must be normalized
    return dot(p,n.xyz)+n.w;
}
 
// Link - exact
float linkSDF(vec3 p,float le,float r1,float r2) {
    vec3 q=vec3(p.x,max(abs(p.y)-le,0.),p.z);
    return length(vec2(length(q.xy)-r1,q.z))-r2;
}
 
// Octahedron - exact
float octahedronSDF(vec3 p,float s) {
    p=abs(p);
    float m=p.x+p.y+p.z-s;
    vec3 q;
    if(3.*p.x<m)q=p.xyz;
    else if(3.*p.y<m)q=p.yzx;
    else if(3.*p.z<m)q=p.zxy;
    else return m*.57735027;
 
    float k=clamp(.5*(q.z-q.y+s),0.,s);
    return length(vec3(q.x,q.y-s+k,q.z-k));
}
 
///////////////////////
// Boolean Operators
///////////////////////
 
vec4 intersectSDF(vec4 a, vec4 b) {
    return a.w > b.w ? a : b;
}
  
vec4 unionSDF(vec4 a, vec4 b) {
    return a.w < b.w? a : b;
}
 
vec4 differenceSDF(vec4 a, vec4 b) {
    return a.w > -b.w? a : vec4(b.rgb,-b.w);
}
 
vec4 GetDist(vec3 p)
{
    // Octahedron
    vec3 o0p = vec3(-3,1,7); // Position
    o0p = p - o0p;
    o0p.xy *= Rotate(-TIME); // Rotate on one axis
    o0p.xz *= Rotate(-TIME);
    vec4 o0 = vec4(OctahedronColor.rgb,octahedronSDF(o0p,1.));
 
    // Link
    vec3 l0p = vec3(0,1,6);
    l0p = p-l0p;
    l0p.xz *= Rotate(-TIME);
    l0p.xy *= Rotate(-TIME);
    vec4 l0 = vec4(LinkColor.rgb,linkSDF(l0p,.2,.5,.2));
 
    // Box
    vec3 b0p = vec3(3,1,7);
    b0p = p - b0p;
    b0p.xy *= Rotate(TIME);
    b0p.xz *= Rotate(TIME);
    vec4 b0 = vec4(BoxColor.rgb,roundBoxSDF(b0p,vec3(.5,.5,.5),.1));
 
    // Plane
    vec4 p0 = vec4(GroundColor.rgb,planeSDF(p,vec4(0,1,0,0)));
 
    // Scene
    vec4 scene = vec4(0);
    scene = unionSDF(l0,o0);
    scene = unionSDF(scene,b0);
    scene = unionSDF(scene,p0);
 
    return scene;
}
                             
float RayMarch(vec3 ro,vec3 rd, inout vec3 dColor)
{
    float dO=0.;//Distane Origin
    for(int i=0;i<MAX_STEPS;i++)
    {
        if(dO>MAX_DIST)
            break;
 
        vec3 p=ro+rd*dO;
        vec4 ds=GetDist(p);// ds is Distance Scene
 
        if(ds.w<SURF_DIST)
        {
            dColor = ds.rgb;
            break;
        }
        dO+=ds.w;
         
    }
    return dO;
}
                             
vec3 GetNormal(vec3 p)
{
    float d=GetDist(p).w;// Distance
    vec2 e=vec2(.01,0);// Epsilon
     
    vec3 n=d-vec3(
        GetDist(p-e.xyy).w,// e.xyy is the same as vec3(.01,0,0). The x of e is .01. this is called a swizzle
        GetDist(p-e.yxy).w,
        GetDist(p-e.yyx).w);
         
    return normalize(n);
}
                                 
vec3 GetLight(vec3 p, vec3 c)
{
    // Diffuse Color
    vec3 color = c.rgb * colorIntensity;
 
    // Directional light
    vec3 lightPos=vec3(5.*sin(TIME),5.,6.+5.*cos(TIME));// Light Position
 
    vec3 l=normalize(lightPos-p);// Light Vector
    vec3 n=GetNormal(p);// Normal Vector
     
    float dif=dot(n,l);// Diffuse light
    dif=clamp(dif,0.,1.);// Clamp so it doesnt go below 0
     
    // Shadows
    float d=RayMarch(p+n*SURF_DIST*2.,l,difColor);
     
    if(d<length(lightPos-p))dif*=.1;
     
    return color * dif;
}
                                 


void main() {



    vec2 uv=(gl_FragCoord.xy-.5*RENDERSIZE.xy)/RENDERSIZE.y;
     
    vec3 ro=vec3(0,1,0);// Ray Origin/Camera
    vec3 rd=normalize(vec3(uv.x,uv.y,1));// Ray Direction
     
    float d=RayMarch(ro,rd,difColor);// Distance
     
    vec3 p=ro+rd*d;
    vec3 color=GetLight(p,difColor);// Diffuse lighting
    // Output to screen
    gl_FragColor = vec4(color,1.0);
}
