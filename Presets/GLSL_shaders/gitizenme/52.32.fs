/*{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/7lSXRt by ChaosOfZen.  Simple SDF morphing example",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": 0.8,
            "LABEL": "scale1",
            "MAX": 0.1,
            "MIN": 1.5,
            "NAME": "scale1",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "scale2",
            "MAX": 0.1,
            "MIN": 1.5,
            "NAME": "scale2",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "scale3",
            "MAX": 0.1,
            "MIN": 1.5,
            "NAME": "scale3",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.25,
            "LABEL": "bpmFactor1",
            "MAX": 10,
            "MIN": 0.01,
            "NAME": "bpmFactor1",
            "TYPE": "float"
        },
        {
            "DEFAULT": 4,
            "LABEL": "focalLength",
            "MAX": 0.1,
            "MIN": 8,
            "NAME": "focalLength",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "rotation",
            "MAX": 6.14,
            "MIN": -6.14,
            "NAME": "rotation",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                0,
                0,
                0,
                1
            ],
            "LABEL": "backgroundColor",
            "MAX": [
                1,
                1,
                1,
                1
            ],
            "MIN": [
                0,
                0,
                0,
                1
            ],
            "NAME": "backgroundColor",
            "TYPE": "color"
        }
    ],
    "ISFVSN": "2"
}
*/


#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .005

#define PI 3.14159265359

const vec3 lightPosition = vec3(0, 3, 4);
const vec3 lightColor    = vec3(0.2, 0.2, 0.2) * 2.;
float bpm = 140.;

struct Surface {
    float signedDistance;
    vec3 color;
};

Surface opUnionSurface(Surface obj1, Surface obj2) {
    if (obj2.signedDistance < obj1.signedDistance) return obj2; // The sd component of the struct holds the "signed distance" value
    return obj1;
}

Surface opIntersectSurface(Surface obj1, Surface obj2) {
    if (obj2.signedDistance < -obj1.signedDistance) return obj1; // The sd component of the struct holds the "signed distance" value
    return obj2;
}

Surface opSubtractSurface(Surface obj1, Surface obj2) {
    if (obj2.signedDistance < obj1.signedDistance) return obj1; // The sd component of the struct holds the "signed distance" value
    return obj2;
}

Surface opSmoothUnionSurface(Surface a, Surface b, float k ) 
{
  float h = clamp(0.5 + 0.5 * (a.signedDistance - b.signedDistance) / k, 0., 1.);
  vec3 c = mix(a.color.rgb, b.color.rgb, h);
  float d = mix(a.signedDistance, b.signedDistance, h) - k * h * (1. - h); 
  return Surface(d, c);
}


mat2 Rotate(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

mat2 Scale(vec2 scale){
    return mat2(scale.x,0.0,
                0.0,scale.y);
}

float sdEllipsoid(vec3 p, vec3 r)
{
  float k0 = length(p/r);
  float k1 = length(p/(r*r));
  return k0*(k0-1.0)/k1;
}

float sdSphere(in vec3 p, in float r) 
{
    vec4 s = vec4(0, 0, 0, r);
    
    float sphereDist = length(p - s.xyz) - s.w;    
    return sphereDist;
}

float sdCube(in vec3 p) 
{
    vec3 b = vec3(0.8);
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

Surface getDist(in vec3 p)
{
    float bbpm = 4.;  // beats per measure
    float spm = (bbpm * (bpm / 60.)) / 4.; // seconds per measure

    vec3 ellipse1Pos = p + vec3(0, scale1 - 1.5, 0);
    ellipse1Pos.xy *= Scale(vec2(scale1));
    ellipse1Pos.xy *= Rotate(spm * bpmFactor1 * TIME);
    ellipse1Pos.xz *= Rotate(spm * bpmFactor1 * TIME);
    vec3 ellipse1size = vec3(1. + scale1, 1. + scale1, 1);
    vec3 ellipse1Color = 0.75 + 0.5 * sin(TIME * 0.5 + p.yxy + vec3(10, 1, 1) - cos(TIME * 0.5 + p.yxy + vec3(10, 1, 1)));
    float ellipse1Distance = sdEllipsoid(ellipse1Pos, ellipse1size);
    ellipse1Distance += sin(ellipse1Pos.x * 3. + TIME * spm) * 0.333 + cos(ellipse1Pos.y * 2. + TIME * spm) * 0.444;
    Surface ellipse1 = Surface(ellipse1Distance, ellipse1Color);

    vec3 ellipse2Pos = p + vec3(1.5, scale2 - 1.5, 0);
    ellipse2Pos.xy *= Scale(vec2(scale2));
    ellipse2Pos.xy *= -Rotate(spm * bpmFactor1 * TIME);
    ellipse2Pos.xz *= Rotate(spm * bpmFactor1 * TIME);
    vec3 ellipse2size = vec3(1. + scale2, 1. + scale2, 1);
    vec3 ellipse2Color = 0.75 + 0.5 * sin(TIME * 0.5 + p.yxy + vec3(1, 10, 1) - cos(TIME * 0.5 + p.yxy + vec3(1, 10, 1)));
    float ellipse2Distance = sdEllipsoid(ellipse2Pos, ellipse2size);
    ellipse2Distance += sin(ellipse2Pos.x * 1.9 + TIME * spm) * 0.368 + cos(ellipse2Pos.y * 1.5 + TIME * spm) * 0.555;
    Surface ellipse2 = Surface(ellipse2Distance, ellipse2Color);
    
    vec3 ellipse3Pos = p + vec3(-1.5, scale3 - 1.5, 0);
    ellipse3Pos.xy *= Scale(vec2(scale3));
    ellipse3Pos.xy *= -Rotate(spm * bpmFactor1 * TIME);
    ellipse3Pos.xz *= -Rotate(spm * bpmFactor1 * TIME);
    vec3 ellipse3size = vec3(1. + scale3, 1. + scale3, 1);
    vec3 ellipse3Color = 0.75 + 0.5 * sin(TIME * 0.5 + p.yxy + vec3(1, 1, 10) - cos(TIME * 0.5 + p.yxy + vec3(1, 1, 10)));
    float ellipse3Distance = sdEllipsoid(ellipse3Pos, ellipse3size);
    ellipse3Distance += sin(ellipse3Pos.x * 3. + TIME * spm) * 0.123 + cos(ellipse3Pos.y * 2. + TIME * spm) * 0.345;
    Surface ellipse3 = Surface(ellipse3Distance, ellipse3Color);

    Surface s = ellipse1;
    s = opSmoothUnionSurface(s, ellipse2, 0.5);
    s = opSmoothUnionSurface(s, ellipse3, 0.5);

    return s;
}

vec3 getNormal(in vec3 p) 
{
    int body;
    float d = getDist(p).signedDistance;
    
    vec2 e = vec2(.01, 0); 
    
    vec3 n = d - vec3(
        getDist(p - e.xyy).signedDistance, 
        getDist(p - e.yxy).signedDistance, 
        getDist(p - e.yyx).signedDistance);
        
    return normalize(n);
}

Surface rayMarch(in vec3 ro, in vec3 rd)
{
    float dO = 0.;
    Surface s = Surface(0., vec3(0));
    
    for (int i = 0; i < MAX_STEPS; i++)
    {
        vec3 p = ro + rd * dO;
        s = getDist(p);
        float dS = s.signedDistance;
        dO += dS;
        
        if (dO > MAX_DIST || dS < SURF_DIST) 
            break;
    }
    s.signedDistance = dO;
    return s;
}

vec3 getLight(in vec3 p, in vec3 rd)
{    
	vec3 normal = getNormal(p);
    vec3 lightDir = normalize(p - lightPosition);
    
    float cosa = pow(0.5 + 0.5 * dot(normal, -lightDir), 3.0);
    float cosr = max(dot(-rd, reflect(lightDir, normal)), 0.0);
    
    vec3 ambient = vec3(0.62);
    vec3 diffuse = vec3(0.5 * cosa);
    vec3 phong = vec3(1.5 * pow(cosr, 16.0));
    
    return lightColor * (ambient + diffuse + phong);
}

void main() {

    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (gl_FragCoord.xy - 0.5 * RENDERSIZE.xy)/RENDERSIZE.y;
    vec3 col = vec3(0);
    vec3 ro = vec3(0., 0., 0.);
    
    // Camera movement
    // float focalLength = 4.;
    // float rotation = TIME / 2.;
    ro = vec3(0., 0., 1.) * focalLength;
    ro.xy *= Rotate(rotation);
    ro.xz *= Rotate(rotation);
    ro.yz *= Rotate(rotation);
    vec3 rd = normalize(vec3(0.) - ro);
    vec3 right = normalize(cross(rd, vec3(0., 1., 0.)));
    vec3 up = cross(right, rd);
   	rd =  normalize(uv.x * right + uv.y * up + rd);
        
    Surface s = rayMarch(ro, rd);
    col = s.color;
    vec3 p = ro + rd * s.signedDistance;   
    // vec3 n = getNormal(p);
    
    if (s.signedDistance < MAX_DIST)
    {
        col *= vec3(getLight(p, rd)) * 2.; 
    }
    else
    {
        vec3 colA = 0.5 + 0.5 * mix(vec3(0), backgroundColor.rgb, uv.yyy);
        vec3 colB = 0.5 + 0.5 * cos(TIME * bpmFactor1 + uv.yyy + vec3(0,2,4));
        col = mix(colA, colB, 0.5);
    }
    
    // Output to screen
    gl_FragColor = vec4(col,1.0);
}
