/*
{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/7l2XRW by ChaosOfZen.  Learning SDF with color using struct to contain position and color",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": [
                0,
                0
            ],
            "LABEL": "position",
            "MAX": [
                1,
                1
            ],
            "MIN": [
                -1,
                -1
            ],
            "NAME": "position",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": 2,
            "LABEL": "scale",
            "MAX": 4.8,
            "MIN": 1,
            "NAME": "scale",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "rotate",
            "MAX": 3.1415,
            "MIN": -3.1415,
            "NAME": "rotate",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                0.3,
                0.3,
                0.3,
                1
            ],
            "LABEL": "backgroundColor",
            "NAME": "backgroundColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0.662745098,
                0.4941176471,
                0,
                1
            ],
            "LABEL": "mixColor",
            "NAME": "mixColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0.5,
                0.5,
                0.5,
                1
            ],
            "LABEL": "lightColor",
            "NAME": "lightColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                1,
                0.39215686274509803,
                0.09803921568627451,
                1
            ],
            "LABEL": "materialColor1",
            "NAME": "materialColor1",
            "TYPE": "color"
        }
    ]
}

*/


const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float PRECISION = 0.001;

struct Surface {
    float signedDistance;
    vec3 color;
};

mat2 Rotate(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

mat2 Scale(vec2 scale){
    return mat2(scale.x,0.0,
                0.0,scale.y);
}

Surface opUnionColor(Surface obj1, Surface obj2) {
    if (obj2.signedDistance < obj1.signedDistance) return obj2; // The sd component of the struct holds the "signed distance" value
    return obj1;
}

Surface opIntersectColor(Surface obj1, Surface obj2) {
    if (obj2.signedDistance < -obj1.signedDistance) return obj1; // The sd component of the struct holds the "signed distance" value
    return obj2;
}

Surface opSubtractColor(Surface obj1, Surface obj2) {
    if (obj2.signedDistance < obj1.signedDistance) return obj1; // The sd component of the struct holds the "signed distance" value
    return obj2;
}

Surface sdSphere(vec3 p, float r, vec3 offset, vec3 color)
{
    float d = length(p - offset) - r;
    return Surface(d, color); // We're initializing a new "Surface" struct here and then returning it
}

Surface sdGyroid(vec3 p, float scale, float thickness, float bias, vec3 color) {
	p *= scale;
    float d = abs( dot( sin(p), cos(p.zxy) * dot(cos(p), sin(p.zxy)) - bias)) / scale - thickness;
    return Surface(d, color);
}


Surface sdPlane(vec3 p, vec3 col) {
    float d = p.y + 1.;
    return Surface(d, col);
}

Surface sdScene(vec3 p) {

    // Surface sphereLeft = sdSphere(vec3(p.x + sin(TIME * 0.1) - cos(TIME * 0.1), p.y  + cos(TIME * 0.1) - sin(TIME * 0.1), p.z), 2., vec3(-1.5, 0, -6), mix(materialColor1.rgb, mixColor.rgb, 0.5));

    float tFactorX = sin(TIME * .25) + cos(TIME);
    float tFactorY = sin(TIME * .25) - cos(TIME);
    float a = atan(p.x + tFactorX, p.y + tFactorY);

    float xFactor = clamp(abs(sin(a * 1. + TIME) * sin(a * 1. - TIME) * sin(a * 1. + TIME)), 0.01, 0.9) * 0.5;

    // p.xy *= Rotate(rotate);
    // p.xy *= Scale(vec2(4.8 - scale));

    vec3 spLeftP = p + vec3(position.x, position.y, 0);
    spLeftP.xy *= Rotate(rotate);
    spLeftP.xy *= Scale(vec2(3. - scale));

    vec3 spRightP = p + vec3(-position.x, position.y, 0);
    spRightP.xy *= Rotate(-rotate);
    spRightP.xy *= Scale(vec2(3. - scale));
    
    vec3 spCenterP = p;
    spCenterP.xy *= Scale(vec2(3. - scale));

    vec3 spTopP = p + vec3(position.x, -position.y, 0);
    spTopP.xy *= Rotate(rotate);
    spTopP.xy *= Scale(vec2(3. - scale));

    vec3 spBottomP = p + vec3(-position.x, position.y, 0);
    spBottomP.xy *= Rotate(rotate);
    spBottomP.xy *= Scale(vec2(3. - scale));

// vec3(p.x + sin(TIME * 0.1) + cos(TIME * 0.1), p.y  + cos(TIME * 0.1) - sin(TIME * 0.1), p.z)
    vec3 c = vec3(mix(materialColor1.rgb, mixColor.rgb, 0.25));
    c.r *= mixColor.g;
    Surface sphereLeft = sdSphere(spLeftP, 1., vec3(-2, 0, -3), c + xFactor);

    c = vec3(mix(materialColor1.rgb, mixColor.rgb, 0.25));
    c.r *= mixColor.g;
    Surface sphereRight = sdSphere(spRightP, 1., vec3(2, 0, -3), c + xFactor);

    c = vec3(mix(materialColor1.rgb, mixColor.brg, 0.25));
    c.r *= mixColor.g;
    Surface sphereCenter = sdSphere(spCenterP, 1., vec3(0, 0, -3), c + xFactor);

    c = vec3(mix(materialColor1.rgb, mixColor.brg, 0.25));
    c.g *= mixColor.r;
    Surface sphereTop = sdSphere(spTopP, 1., vec3(0, 2, -3), c + xFactor);

    c = vec3(mix(materialColor1.rgb, mixColor.brg, 0.25));
    c.b *= mixColor.r;
    Surface sphereBottom = sdSphere(spBottomP, 1., vec3(0, -2, -3), c + xFactor);

    // float mixValue = distance(p, vec3(0, 0, 0));

    // Surface sdPlaneFloor = sdPlane(vec3(p.x, p.y, p.z), mix(vec3(1.0, 0.55, 0.0), vec3(0.226,0.000,0.615), mixValue));
    // Surface sdPlaneCeil = sdPlane(vec3(p.x, p.y, p.z), mix(vec3(1.0, 0.55, 0.0), vec3(0.226,0.000,0.615), mixValue));

    Surface co =  sphereCenter; // co = closest object containing "signed distance" and color
    co = opUnionColor(co, sphereRight);
    co = opUnionColor(co, sphereLeft);
    co = opUnionColor(co, sphereTop);
    co = opUnionColor(co, sphereBottom);
    
    return co;
}

Surface rayMarch(vec3 ro, vec3 rd, float start, float end) {
    float depth = start;
    Surface co; // closest object

    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        vec3 p = ro + depth * rd;
        co = sdScene(p);
        depth += co.signedDistance;
        if (co.signedDistance < PRECISION || depth > end) break;
    }

    co.signedDistance = depth;

    return co;
}

vec3 calcNormal(in vec3 p) {
    vec2 e = vec2(1.0, -1.0) * 0.0005; // epsilon
    return normalize(
      e.xyy * sdScene(p + e.xyy).signedDistance +
      e.yyx * sdScene(p + e.yyx).signedDistance +
      e.yxy * sdScene(p + e.yxy).signedDistance +
      e.xxx * sdScene(p + e.xxx).signedDistance);
}

vec3 Transform(vec3 p) {
    p.xy *= Rotate(p.z*.55);
    p.y -= .9;
    return p;
}

vec3 shader(vec2 uv) {
    // vec3 backgroundColor = vec3(0.1, .1, .1);
    // vec3 materialColor = vec3(0.5, .1, .9);

    float t = TIME;
    vec3 color = vec3(0);

    // uv.xy *= Rotate(rotate);
    // uv.xy *= Scale(vec2(4.8 - scale));
    uv += sin(uv * 20. + t * 0.5) * .029;
    // uv += abs(dot(sin(uv * 10. + t * 0.5), -cos(uv * 10. - t * 0.5))) * .028;
    // uv += abs(dot(sin(uv * 20. + t * 0.5), -cos(uv * 20. - t * 0.5))) * .028;

    vec3 ro = vec3(0, 0, 4); // ray origin that represents camera position
    // ro.yz *= Rotate(-position.y*3.14+1.);
    // ro.xz *= Rotate(-position.x*6.2831);

    vec3 rd = normalize(vec3(uv, -1)); // ray direction

    Surface co = rayMarch(ro, rd, MIN_DIST, MAX_DIST); // closest object

    float mixValue = distance(uv, vec2(0, 0.5));
    if (co.signedDistance < MAX_DIST) {
        vec3 p = ro + rd * co.signedDistance; // point on sphere or floor we discovered from ray marching
        vec3 normal = calcNormal(p);

        p = Transform(p);

        vec3 lightPosition = vec3(sin(TIME) - cos(TIME) + 2., 2, 7);
        vec3 lightDirection = normalize(lightPosition - p);

        // Calculate diffuse reflection by taking the dot product of 
        // the normal and the light direction.
        float dif = clamp(dot(normal, lightDirection), 0.3, 0.8);

        // Multiply the diffuse reflection value by an orange color and add a bit
        // of the background color to the sphere to blend it more with the background.
        color = dif * co.color.rgb + lightColor.rgb * .002;

    } else {
        color = mix(mixColor.rgb, backgroundColor.rgb, mixValue);
    }
    return color;
}


void main() {
    vec2 uv = (gl_FragCoord.xy-.5*RENDERSIZE.xy)/RENDERSIZE.y;
    vec3 col = shader(uv);
    // Output to screen
    gl_FragColor = vec4(col, 1.0);
}
