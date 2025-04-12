/*{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/NdVSz1 by ChaosOfZen.  One extra fetch is required if you're already computing normals, also included (unused) is a 5-tap version if you want a different epsilon on the curvature check.  Here the curvature is used for coloring and isolines display.",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": [
                0.15,
                0.59
            ],
            "LABEL": "rotate",
            "MAX": [
                1,
                1
            ],
            "MIN": [
                0,
                0
            ],
            "NAME": "rotate",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                0,
                0.4,
                0.97,
                1
            ],
            "LABEL": "color",
            "NAME": "color",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0.9,
                0.5,
                0.1,
                1
            ],
            "LABEL": "mixColor",
            "NAME": "mixColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": 400,
            "LABEL": "specularSpread",
            "MAX": 500,
            "MIN": 4,
            "NAME": "specularSpread",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "mapFreq",
            "MAX": 10.5,
            "MIN": 0,
            "NAME": "mapFreq",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "mapTime",
            "MAX": 60,
            "MIN": -60,
            "NAME": "mapTime",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "scale",
            "MAX": 1.5,
            "MIN": 0.75,
            "NAME": "scale",
            "TYPE": "float"
        },
        {
            "DEFAULT": 15,
            "LABEL": "vIntesity",
            "MAX": 20,
            "MIN": 0.5,
            "NAME": "vIntesity",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.25,
            "LABEL": "vSize",
            "MAX": 0,
            "MIN": 0.65,
            "NAME": "vSize",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/



#define ITERATIONS 80
#define MAX_DIST 10.
#define time TIME
// #define specularSpread 400.
// #define mapTime TIME

mat2 mm2(in float a)
{
    float c = cos(a);
    float s = sin(a);
    return mat2(c,s,-s,c);
}

float map(vec3 p)
{
    p /= scale;

    p.x += sin(p.y * 4. + mapTime + cos(p.z)) * 0.15;
    float d = length(p) - 1.;
    float st = sin(mapTime * 0.42) * 0.25 + 0.75; 
    d += cos(p.x * mapFreq + mapTime * .3 + sin(p.z * mapFreq + mapTime * .5 + sin(p.y * mapFreq + mapTime * .7))) * 0.0075 * st;
    
    return d;
}

float march(in vec3 ro, in vec3 rd)
{
	float precision = 0.001;
    float h = precision * 2.0;
    float d = 0.;
    for( int i=0; i<ITERATIONS; i++ )
    {
        if( abs(h) < precision || d > MAX_DIST ) break;
        d += h;
	    float res = map(ro + rd * d);
        h = res;
    }
	return d;
}

//5 taps total, returns both normal and curvature
vec3 norcurv(in vec3 p, out float curv)
{
    vec2 e = vec2(-1., 1.)*0.01;   
    float t1 = map(p + e.yxx), t2 = map(p + e.xxy);
    float t3 = map(p + e.xyx), t4 = map(p + e.yyy);

    curv = .25 / e.y * (t1 + t2 + t3 + t4 - 4.0 * map(p));
    return normalize(e.yxx*t1 + e.xxy*t2 + e.xyx*t3 + e.yyy*t4);
}

//Curvature only, 5 taps, with epsilon width as input
float curv(in vec3 p, in float w)
{
    vec2 e = vec2(-1., 1.) * w;   
    
    float t1 = map(p + e.yxx), t2 = map(p + e.xxy);
    float t3 = map(p + e.xyx), t4 = map(p + e.yyy);
    
    return .25 / e.y * (t1 + t2 + t3 + t4 - 4.0*map(p));
}

//Curvature in 7-tap (more accurate)
float curv2(in vec3 p, in float w)
{
    vec3 e = vec3(w, 0, 0);
    
    float t1 = map(p + e.xyy), t2 = map(p - e.xyy);
    float t3 = map(p + e.yxy), t4 = map(p - e.yxy);
    float t5 = map(p + e.yyx), t6 = map(p - e.yyx);
    
    return .25 / e.x * (t1 + t2 + t3 + t4 + t5 + t6 - 6.0*map(p));
}

void main() {

	vec2 p = isf_FragNormCoord - 0.5;
	p.x *= RENDERSIZE.x / RENDERSIZE.y;
	vec2 mo = rotate;
	
    vec3 ro = vec3(0., 0., 4.);
    ro.xz *= mm2(0.05 + rotate.x * 3.);
    ro.yz *= mm2(0.05 + rotate.y * 3.);
	vec3 ta = vec3(0);
    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(vec3(0., 1., 0.), ww));
    vec3 vv = normalize(cross(ww, uu));
    vec3 rd = normalize(p.x * uu + p.y * vv + 1.5 * ww);
	
	float rz = march(ro, rd);
	
    vec3 col = color.rgb;

    if ( rz < MAX_DIST )
    {
        vec3 position = ro + rz * rd;
        float curve;
        vec3 normalCurve = norcurv(position, curve);
        curve = curv2(position, 0.01);
        vec3 light = normalize( vec3(.0, 1., 0.) );
        float diffuse = clamp(dot( normalCurve, light ), 0., 1.);
        float background = clamp( dot( normalCurve, -light), 0.0, 1.0 );
        float specular = pow(clamp( dot( reflect(rd, normalCurve), light ), 0.0, 1.0 ), specularSpread);
        float frequency = pow( clamp(1.0 + dot(normalCurve, rd), 0.0, 1.0), 2.0);
        vec3 bkgDiff = vec3(col.r * 0.10, col.g * 0.11, col.b * 0.13);
        bkgDiff += background * vec3(col * 0.1);
        bkgDiff += diffuse * vec3(col.r * 1.00, col.g * 0.90, col.b * 0.60);
        col = abs(sin(vec3(col.r * 0.2, col.g * 0.5, col.b * .9) + clamp(curve * 80., 0., 1.) * 1.2));
        col = mix(col, mixColor.rgb, .5);
        col = col * bkgDiff + col * specular +.3 * frequency * mix(col, vec3(1), 0.5);
        col *= smoothstep(-1., -.9, sin(curve * 200.)) * 0.15 + 0.85;
    }
    else {
        vec2 uv = isf_FragNormCoord;
        uv *=  1.0 - uv.yx;
        float vig = uv.x * uv.y * vIntesity; // multiply with sth for intensity
        vig = pow(vig, vSize); // change pow for modifying the extend of the  vignette
        col *= vec3(0.75);
        col *= vig;
    }
	
	gl_FragColor = vec4( col, 1.0 );
}
