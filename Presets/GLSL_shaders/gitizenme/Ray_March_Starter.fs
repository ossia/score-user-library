/*{
    "CATEGORIES": [
        "Ray Marching",
        "Color",
        "Primitives",
        "Audio"
    ],
    "DESCRIPTION": "52.22 - 52 tracks in 52 weeks by ChaosOfZen",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": [
                1,
                1,
                1,
                1
            ],
            "LABEL": "Ground Color",
            "NAME": "groundColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0,
                0,
                1,
                1
            ],
            "LABEL": "Box Color 1",
            "NAME": "boxColor1",
            "TYPE": "color"
        },
        {
            "DEFAULT": 0,
            "LABEL": "Box 1 Rotation",
            "MAX": 6.14,
            "MIN": -6.14,
            "NAME": "box1Rotation",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "Box 1 Scale",
            "MAX": 3,
            "MIN": 0.1,
            "NAME": "box1Scale",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "Color Intensity",
            "MAX": 1,
            "MIN": 0,
            "NAME": "colorIntensity",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "LABEL": "Box 1 Pos Y",
            "MAX": 10,
            "MIN": -0.4,
            "NAME": "box1PosY",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/


//precision highp float;
 
// Constants
#define PI 3.1415925359
#define MAX_STEPS 100// Mar Raymarching steps
#define MAX_DIST 100.// Max Raymarching distance
#define SURF_DIST.01// Surface Distance
 
vec3 difColor = vec3(1.0, 1.0, 1.0); // Diffuse Color
 
mat2 Rotate(float a) {
    float s=sin(a); 
    float c=cos(a);
    return mat2(c,-s,s,c);
}
 
///////////////////////
// Primitives
///////////////////////

float planeSDF( vec3 p )
{
	return p.y;
}

float sphereSDF( vec3 p, float s )
{
    return length(p)-s;
}

float boxSDF(vec3 p, vec3 b) {
    vec3 q = abs(p)-b;
	return length(max(q, 0.))+min(max(q.x, max(q.y, q.z)), 0.);
}

// Round Box - exact
float roundBoxSDF(vec3 p,vec3 b,float r) {
    vec3 q=abs(p)-b;
    return (length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.)-r);
}

// arbitrary orientation
float cylinderSDF(vec3 p, vec3 a, vec3 b, float r)
{
    vec3 pa = p - a;
    vec3 ba = b - a;
    float baba = dot(ba,ba);
    float paba = dot(pa,ba);

    float x = length(pa*baba-ba*paba) - r*baba;
    float y = abs(paba-baba*0.5)-baba*0.5;
    float x2 = x*x;
    float y2 = y*y*baba;
    float d = (max(x,y)<0.0)?-min(x2,y2):(((x>0.0)?x2:0.0)+((y>0.0)?y2:0.0));
    return sign(d)*sqrt(abs(d))/baba;
}
 
// Plane - exact
float planeSDF(vec3 p,vec4 n) {
    // n must be normalized
    return dot(p,n.xyz)+n.w;
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
    // Round Box
    vec3 b0p = vec3(0,box1PosY,7);
    b0p = p - b0p;
    b0p.xy *= Rotate(box1Rotation);
    b0p.xz *= Rotate(box1Rotation);
    float rb0 = roundBoxSDF(b0p,vec3(.5,.5,.5)*box1Scale,.1);
    vec4 b0 = vec4(boxColor1.rgb,rb0);

    // Box
    vec3 b1p = vec3(0, 1.5, 7);
    b1p = p - b1p;

    float sinMul = 1.;
    float cosMul = 1.;
    float xMul = 1.;
    float yMul = 1.;
    float xDivide = 1.;
    float yDivide = 1.;
    float xSpeed = 1.;
    float ySpeed = 1.;

    b1p.x += sinMul * sin(b1p.y * yMul + TIME * xSpeed) + cos(b1p.y / yDivide - TIME);
    b1p.y += cosMul * cos(b1p.x * xMul - TIME * ySpeed) - sin(b1p.x / xDivide - TIME);
    b1p.z += cosMul * sin(b1p.z * xMul - TIME * ySpeed) - sin(b1p.y / xDivide - TIME);

    float bs1 = sphereSDF(b1p, 1.5);
    vec4 b1 = vec4(boxColor1.rgb,bs1);

    float cs1 = cylinderSDF(
        p-vec3( 3, 1, 5), 
        vec3(0.1,-0.1,0.0), 
        vec3(-0.2,0.35,0.1), 
        0.15);
    vec4 c1 = vec4(boxColor1.rgb,cs1);

    // Plane
    vec4 p0 = vec4(groundColor.rgb,planeSDF(p));
 
    // Scene
    vec4 scene = vec4(b0);
    scene = unionSDF(scene, b1);
    scene = unionSDF(scene, c1);
    scene = unionSDF(scene, p0);
 
    return scene;
}
                             
float RayMarch(vec3 ro, vec3 rd, inout vec3 dColor)
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
        GetDist(p-e.xyy).w,
        GetDist(p-e.yxy).w,
        GetDist(p-e.yyx).w);
         
    return normalize(n);
}
                                 
vec3 GetLight(vec3 p, vec3 c)
{
    // Diffuse Color
    vec3 color = c.rgb * colorIntensity;
 
    float bpm = TIME*(240./960.);
    // Directional light
    vec3 lightPos=vec3(5.,5.,-1.);// Light Position
 
    vec3 l=normalize(lightPos-p);// Light Vector
    vec3 n=GetNormal(p);// Normal Vector
     
    float dif=dot(n,l);// Diffuse light
    dif=clamp(dif,0.,1.);// Clamp so it doesnt go below 0
     
    // Shadows
    float d=RayMarch(p+n*SURF_DIST*40.,l,difColor);
     
    if(d<length(lightPos-p))dif*=.6;
     
    return color * dif;
}
                                 


void main() {
    vec2 uv=(gl_FragCoord.xy-.5*RENDERSIZE.xy)/RENDERSIZE.y;
     
    vec3 ro=vec3(0,3,0);// Ray Origin/Camera
    vec3 rd=normalize(vec3(uv.x,uv.y,0.75));// Ray Direction
    
    difColor *= groundColor.rgb;
    float d=RayMarch(ro,rd,difColor);// Distance
     
    vec3 p=ro+rd*d;
    vec3 color=GetLight(p,difColor);// Diffuse lighting
    // Output to screen
    gl_FragColor = vec4(color,1.0);
}
