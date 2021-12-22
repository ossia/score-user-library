/*{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/ltfXzj by victor_shepardson.  improvised some psychedelic nonsense... getting 2001 and enter the void vibes",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": [
                1,
                0.2,
                0,
                1
            ],
            "NAME": "accentColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0,
                0.2,
                0.7,
                1
            ],
            "NAME": "mainColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": 0.2,
            "MAX": 1,
            "MIN": 0,
            "NAME": "zoomFactor",
            "TYPE": "float"
        },
        {
            "DEFAULT": 2,
            "MAX": 10,
            "MIN": 2,
            "NAME": "scaleFactor",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.2,
            "MAX": 1,
            "MIN": 0.1,
            "NAME": "WP",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "MAX": 25,
            "MIN": 0,
            "NAME": "BLUR",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/


const float pi = 3.14159;
 
float sigmoid(float x){
 	return x/(1.+abs(x));   
}

float iter(vec2 p, vec4 a, vec4 wt, vec4 ws, float t, float m, float stereo){
    float wp = WP;
    vec4 phase = vec4(mod(t, wp), mod(t+wp*.25, wp), mod(t+wp*.5, wp), mod(t+wp*.75, wp))/wp;
    float zoom = 1./(1.+ zoomFactor * (p.x*p.x+p.y*p.y));
    vec4 scale = zoom*pow(vec4(scaleFactor), -4.*phase);
    vec4 ms = .5-.5*cos(2.*pi*phase);
    vec4 pan = stereo/scale*(1.-phase)*(1.-phase);
    vec4 v = ms*sin( wt*(t+m) + (m+ws*scale)*((p.x+pan) * cos((t+m)*a) + p.y * sin((t+m)*a)));
    return sigmoid(v.x+v.y+v.z+v.w+m);
}

vec3 scene(float gt, vec2 uv, vec4 a0, vec4 wt0, vec4 ws0, float blur){
    //time modulation
    float tm = mod(.0411*gt, 1.);
    tm = sin(2.*pi*tm*tm);
    float t = (.04*gt + .05*tm);
    
    float stereo = 1.*(sigmoid(2.*(sin(1.325*t*cos(.5*t))+sin(-.7*t*sin(.77*t)))));//+sin(-17.*t)+sin(10.*t))));
    //t = 0.;
    //also apply spatial offset
    uv+= .5*sin(.33*t)*vec2(cos(t), sin(t));
    
    //wildly iterate and divide
    float p0 = iter(uv, a0, wt0, ws0, t, 0., stereo);
    
   	float p1 = iter(uv, a0, wt0, ws0, t, p0, stereo);
    
    float p2 = sigmoid(p0/(p1+blur));
    
    float p3 = iter(uv, a0, wt0, ws0, t, p2, stereo);
    
    float p4 = sigmoid(p3/(p2+blur));
    
    float p5 = iter(uv, a0, wt0, ws0, t, p4, stereo);
    
    float p6 = sigmoid(p4/(p5+blur));
    
    float p7 = iter(uv, a0, wt0, ws0, t, p6, stereo);
    
    float p8 = sigmoid(p4/(p2+blur));
    
    float p9 = sigmoid(p8/(p7+blur));
    
    float p10 = iter(uv, a0, wt0, ws0, t, p8, stereo);
    
    float p11 = iter(uv, a0, wt0, ws0, t, p9, stereo);
    
    float p12 = sigmoid(p11/(p10+blur));
    
    float p13 = iter(uv, a0, wt0, ws0, t, p12, stereo);
    
    //colors
    vec3 accent_color = accentColor.rgb;//vec3(0.99,0.5,0.2);
    /*float r = sigmoid(-1.+2.*p0+p1-max(1.*p3,0.)+p5+p7+p10+p11+p13);
    float g = sigmoid(-1.+2.*p0-max(1.*p1,0.)-max(2.*p3,0.)-max(2.*p5,0.)+p7+p10+p11+p13);
    float b = sigmoid(0.+1.5*p0+p1+p3+-max(2.*p5,0.)+p7+p10+p11+p13);
    */
    float r = clamp(sigmoid(p0+p1+p5+p7+p10+p11+p13), 0., accentColor.r);
    float g = clamp(sigmoid(p0-p1+p3+p7+p10+p11), 0., accentColor.g);
    float b = clamp(sigmoid(p0+p1+p3+p5+p11+p13), 0., accentColor.b);
    
    
    vec3 c = max(vec3(0), clamp(.4+.6*vec3(r,g,b), vec3(0), vec3(0.8)));
    
    float eps = .4;
    float canary = min(abs(p1), abs(p2));
    canary = min(canary, abs(p5));
    // canary = min(canary, abs(p6));
    canary = min(canary, abs(p7));
    canary = min(canary, abs(p10));
    float m = max(0.,eps-canary)/eps;
    m = sigmoid((m-.5)*700./(1.+10.*blur))*.5+.5;
    //m = m*m*m*m*m*m*m*m*m*m;
    vec3 m3 = m*(1.-accent_color);
    // c *= .8*(1.-m3)+.3;//mix(c, vec3(0.), m);
    c = mix(c, mainColor.rgb, m3);
    
    return c;
}

mat2 rot(float a)
{
  float s = sin(a), c = cos(a);
  return mat2(c,-s,s,c);
}

int bpm = 60;
float bbpm = 1. / 4.;  // beats per measure
float spm = (bbpm * (float(bpm) / 60.)); // seconds per measure

void main() {
    float s = min(RENDERSIZE.x, RENDERSIZE.y);
   	vec2 uv = (2.*gl_FragCoord.xy - vec2(RENDERSIZE.xy)) / s;
    
    uv *= rot(sin(TIME * spm) - cos(TIME * spm));

    float blur = BLUR*(uv.x*uv.x+uv.y*uv.y);
    
    //angular, spatial and temporal frequencies
    vec4 a0 = pi*vec4(.1, -.11, .111, -.1111); 
    vec4 wt0 = 2.*pi*vec4(.3);//.3333, .333, .33, .3);
    vec4 ws0 = 2.5*vec4(11., 13., 11., 5.);
    //aa and motion blur
    float mb = 1.;
    float t = TIME * spm;
    vec3 c = scene(t, uv, a0, wt0, ws0, blur)
        + scene(t-mb*.00185, uv+(1.+blur)*vec2(.66/s, 0.), a0, wt0, ws0, blur)
        + scene(t-mb*.00370, uv+(1.+blur)*vec2(-.66/s, 0.), a0, wt0, ws0, blur)
        + scene(t-mb*.00555, uv+(1.+blur)*vec2(0., .66/s), a0, wt0, ws0, blur)
        + scene(t-mb*.00741, uv+(1.+blur)*vec2(0., -.66/s), a0, wt0, ws0, blur)
        + scene(t-mb*.00926, uv+(1.+blur)*vec2(.5/s, .5/s), a0, wt0, ws0, blur)
        + scene(t-mb*.01111, uv+(1.+blur)*vec2(-.5/s, .5/s), a0, wt0, ws0, blur)
        + scene(t-mb*.01296, uv+(1.+blur)*vec2(-.5/s, -.5/s), a0, wt0, ws0, blur)
        + scene(t-mb*.01481, uv+(1.+blur)*vec2(.5/s, -.5/s), a0, wt0, ws0, blur)
        ;
    c /= 7.;
    
    gl_FragColor = vec4(c,1.0);
}
