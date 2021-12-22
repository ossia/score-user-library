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
            "DEFAULT": [
                1,
                0,
                0,
                0
            ],
            "LABEL": "Box Color 2",
            "NAME": "boxColor2",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0,
                1,
                0,
                1
            ],
            "LABEL": "Box Color 3",
            "NAME": "boxColor3",
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
            "DEFAULT": 0,
            "LABEL": "Box 2 Rotation",
            "MAX": 6.14,
            "MIN": -6.14,
            "NAME": "box2Rotation",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "Box 3 Rotation",
            "MAX": 6.14,
            "MIN": -6.14,
            "NAME": "box3Rotation",
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
            "LABEL": "Box 2 Scale",
            "MAX": 3,
            "MIN": 0.1,
            "NAME": "box2Scale",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "Box 3 Scale",
            "MAX": 3,
            "MIN": 0.1,
            "NAME": "box3Scale",
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
        },
        {
            "DEFAULT": 0.5,
            "LABEL": "Box 2 Pos Y",
            "MAX": 10,
            "MIN": -0.4,
            "NAME": "box2PosY",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "LABEL": "Box 3 Pos Z",
            "MAX": 10,
            "MIN": -0.4,
            "NAME": "box3PosY",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/


//precision highp float;
 
// Constants
#define PI 3.1415925359 
#define MAX_STEPS 100 // Mar Raymarching steps
#define MAX_DIST 100. // Max Raymarching distance
#define SURF_DIST .01 // Surface Distance
 
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
    return (length(max(q,0.))+min(max(q.x,max(q.y,q.z)),0.)-r);
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
    // Box
    vec3 b0p = vec3(0,box1PosY,7);
    b0p = p - b0p;
    b0p.xy *= Rotate(box1Rotation);
    b0p.xz *= Rotate(box1Rotation);
    float rb0 = roundBoxSDF(b0p,vec3(.5,.5,.5)*box1Scale,.1);
    rb0 += sin(p.x*5.+TIME)*0.1 + cos(p.z*2.+TIME)*0.3;
    vec4 b0 = vec4(boxColor1.rgb,rb0);

    vec3 b1p = vec3(-5,box2PosY,7);
    b1p = p - b1p;
    b1p.xy *= Rotate(box2Rotation);
    b1p.xz *= Rotate(box2Rotation);
    float rb1 = roundBoxSDF(b1p,vec3(.5,.5,.5)*box2Scale,.1);
    rb1 += sin(p.x*5.+TIME)*0.15 + cos(p.z*2.+TIME)*0.25;
    vec4 b1 = vec4(boxColor2.rgb,rb1);

    vec3 b2p = vec3(5,box3PosY,7);
    b2p = p - b2p;
    b2p.xy *= Rotate(box3Rotation);
    b2p.xz *= Rotate(box3Rotation);
    float rb2 = roundBoxSDF(b2p,vec3(.5,.5,.5)*box3Scale,.1);
    rb2 += sin(p.x*5.+TIME)*0.15 + cos(p.z*2.+TIME)*0.25;
    vec4 b2 = vec4(boxColor3.rgb,rb2);

    // Plane
    vec4 p0 = vec4(groundColor.rgb,planeSDF(p,vec4(0,1,0,0)));
 
    // Scene
    vec4 scene = vec4(0);
    // scene = unionSDF(l0,o0);
    // scene = unionSDF(scene,b0);
    scene = unionSDF(b0,b1);
    scene = unionSDF(scene,b2);
    scene = unionSDF(scene,p0);
 
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
    vec3 lightPos=vec3(5.*sin(TIME),10.,-6.+5.*cos(TIME));// Light Position
 
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
