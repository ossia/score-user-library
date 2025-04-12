/*{
    "CATEGORIES": [
        "Zen",
        "Enso"
    ],
    "CREDIT": "Chaos.of.Zen",
    "DESCRIPTION": "Enso/Zen symbol",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": false,
            "LABEL": "pulse",
            "NAME": "pulse",
            "TYPE": "bool"
        },
        {
            "DEFAULT": true,
            "LABEL": "rotation",
            "NAME": "rotation",
            "TYPE": "bool"
        },
        {
            "DEFAULT": 3,
            "LABEL": "Rotation Speed",
            "MAX": 64,
            "MIN": -64,
            "NAME": "rotationSpeed",
            "TYPE": "float"
        },
        {
            "DEFAULT": 2,
            "LABEL": "Pixel Smoothing",
            "MAX": 64,
            "MIN": 1,
            "NAME": "pixelSmoothing",
            "TYPE": "float"
        },
        {
            "DEFAULT": 3.14,
            "LABEL": "rotationAngle",
            "MAX": 6.28,
            "MIN": 0,
            "NAME": "rotationAngle",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                0,
                0,
                0,
                1
            ],
            "LABEL": "symbolColor",
            "NAME": "symbolColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0,
                0,
                1,
                1
            ],
            "LABEL": "blendColor",
            "NAME": "blendColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                1,
                1,
                1,
                1
            ],
            "LABEL": "backgroundColor",
            "NAME": "backgroundColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": -0.5,
            "LABEL": "size",
            "MAX": 100,
            "MIN": -100,
            "NAME": "size",
            "TYPE": "float"
        },
        {
            "DEFAULT": 6,
            "LABEL": "seconds",
            "MAX": 64,
            "MIN": 0,
            "NAME": "seconds",
            "TYPE": "float"
        },
        {
            "DEFAULT": 32,
            "LABEL": "Number of Rings",
            "MAX": 256,
            "MIN": 1,
            "NAME": "rings",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.12,
            "LABEL": "Warp",
            "MAX": 64,
            "MIN": -64,
            "NAME": "warp",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/


#define PI 3.14159265359
#define HALF_PI 1.57079632675
#define TWO_PI 6.283185307

// #define rotationAngle PI

// #define pulse true
// #define rotation true

vec2 randomNoise(vec2 uv)
{    
    uv = vec2( dot(uv,vec2(127.1,311.7)),
              dot(uv,vec2(29.5,183.3)) );
    return -1.0 + 2.0*fract(sin(uv)*43758.5453123);
}

float randomVignette(vec2 uv)
{
    return fract(sin(dot(uv.yx,vec2(14.7891,43.123)))*312991.41235);
}

float randomMovement(in float x)
{
    return fract(sin(x)*43758.5453123);
}


float vignetteNoise(vec2 uv) {
    vec2 ring = floor(uv);
    vec2 f = fract(uv);

    vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( dot( randomNoise(ring + vec2(0.0,0.0)), f - vec2(0.0,0.0) ),
                     dot( randomNoise(ring + vec2(1.0,0.0)), f - vec2(1.0,0.0) ), u.x),
                mix( dot( randomNoise(ring + vec2(0.0,1.0)), f - vec2(0.0,1.0) ),
                     dot( randomNoise(ring + vec2(1.0,1.0)), f - vec2(1.0,1.0) ), u.x), u.y);
}

mat2 rotate(float angle)
{
    return mat2( cos(angle),-sin(angle),sin(angle),cos(angle) );
}

vec2 ratio(vec2 uv)
{
    return  vec2(
            max(uv.x/uv.y,1.0),
            max(uv.y/uv.x,1.0)
            );
}

vec2 center(vec2 uv)
{
    float aspect = RENDERSIZE.x/RENDERSIZE.y;
    uv.x = uv.x * aspect - aspect * 0.5 + 0.5;
    return uv;
}

vec3 time()
{
    float period = mod(TIME,seconds);
    vec3 t = vec3(fract(TIME/seconds),period, 1.0-fract(period));
    return t;       // return fract(length),period,period phase
}

float zen(vec2 uv, vec3 t)
{
    uv = uv * 2.0 - 1.0;

    float seed = 29192.173;
    float center = length(uv-0.5) - 0.5;

    float n_scale = warp;

    float n_1 = vignetteNoise(uv + PI) * n_scale;
    float n_2 = vignetteNoise(uv+seed - PI) * n_scale;
    if(rotation) {
        float n_1 = vignetteNoise(uv + sin(PI*t.x)) * n_scale;
        float n_2 = vignetteNoise(uv+seed - sin(PI*t.x)) * n_scale;
    }

    float d = 1.0;
    for(float ring = 1.; ring <= rings; ring++)
    {
        float spread = 1.0 / ring;
        float speed = ceil(rotationSpeed*spread);
        float r = randomMovement(ring*5.0 + seed);
        float r_scalar = r * 2.0 - 1.0;

        vec2 pos = uv - vec2(0.0);

        pos *= rotate(rotationAngle);

        if(rotation) {
            pos += vec2(0.01) * rotate(TWO_PI * r_scalar + TWO_PI * t.x * speed * sign(r_scalar));
            pos *= rotate(TWO_PI * r_scalar + TWO_PI * t.x * speed * sign(r_scalar) + vignetteNoise(pos + float(ring) + TIME) );
            pos += mix(n_1,n_2,0.5+0.5*sin(TWO_PI*t.x*speed));
            pos *= rotate(TWO_PI * r_scalar + TWO_PI * t.x * speed * sign(r_scalar) + vignetteNoise(pos + float(ring) + TIME) );
        }

        float s = .45 + .126 * r;

        float a = atan(pos.y,pos.x)/PI;
        a = abs(a);
        a = smoothstep(0.0,1.0,a);

        float c = length(pos);
        c = abs(c-s);
        c -= 0.0004 + .0125 * a;

        d = min(d,c);
    }

    return d;
}

float scene(vec2 uv, vec3 t) {
    return zen(uv, t);
}

void main() {
    // timing
    vec3 t = time();
    // space
    vec2 uv = isf_FragNormCoord;
    uv = center( uv );
    uv = uv * 2.0 - 1.0;

    // float size = -0.5;
    if(pulse) 
        uv = uv * (1.0 + .03 * sin(TWO_PI*t.x));
    else
        uv = uv * (1.0 + .03 * TWO_PI*-size);

    uv = uv * 0.5 + 0.5;
    // scene
    float s = scene(uv, t);

    float smoothing = ratio(RENDERSIZE.xy).x/RENDERSIZE.x*pixelSmoothing;
    
    // symbol color
    vec4 color = vec4(symbolColor.rgb, 1.0);

    // blend color
    color = mix(color,vec4(blendColor.rgb, 1.0),1.0-smoothstep(-smoothing,smoothing,s));

    // background color
    color = mix(color,vec4(backgroundColor.rgb,1.0),smoothstep(-smoothing,smoothing,s));

    // vignette
    float size = length(uv-.5)-1.33;
    float vignette = (size) * 0.75 + randomVignette(uv) *.08;        
    color = mix(color,vec4(0.0, 0.0, 0.0, 1.0),vignette+.5);
	float d = vignetteNoise(uv*7.0+TIME*0.25);  
    vec4 vColor = vec4(color.rgb,mix(1., 1.+.75*d, 1.0-smoothstep(-smoothing,smoothing,s)));

    gl_FragColor = vColor;
//     gl_FragColor = vec4(color);
}

