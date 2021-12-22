/*{
    "CATEGORIES": [
        "52",
        "52.27"
    ],
    "DESCRIPTION": "Inspired by https://www.shadertoy.com/view/WsV3D1 by atzmael. ",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": [
                0.01,
                0.01
            ],
            "LABEL": "Circle 1 Min Max",
            "MAX": [
                1,
                1
            ],
            "MIN": [
                0.01,
                0.01
            ],
            "NAME": "circle1MinMax",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                0.01,
                0.01
            ],
            "LABEL": "Circle 2 Min Max",
            "MAX": [
                1,
                1
            ],
            "MIN": [
                0.01,
                0.01
            ],
            "NAME": "circle2MinMax",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                0.01,
                0.01
            ],
            "LABEL": "Circle 3 Min Max",
            "MAX": [
                1,
                1
            ],
            "MIN": [
                0.01,
                0.01
            ],
            "NAME": "circle3MinMax",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                0.01,
                0.01
            ],
            "LABEL": "Circle 4 Min Max",
            "MAX": [
                1,
                1
            ],
            "MIN": [
                0.01,
                0.01
            ],
            "NAME": "circle4MinMax",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                0.01,
                0.01
            ],
            "LABEL": "Circle 5 Min Max",
            "MAX": [
                1,
                1
            ],
            "MIN": [
                0.01,
                0.01
            ],
            "NAME": "circle5MinMax",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                0.01,
                0.01
            ],
            "LABEL": "Circle 6 Min Max",
            "MAX": [
                1,
                1
            ],
            "MIN": [
                0.01,
                0.01
            ],
            "NAME": "circle6MinMax",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                0.01,
                0.01
            ],
            "LABEL": "Circle 7 Min Max",
            "MAX": [
                1,
                1
            ],
            "MIN": [
                0.01,
                0.01
            ],
            "NAME": "circle7MinMax",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                0.01,
                0.01
            ],
            "LABEL": "Circle 8 Min Max",
            "MAX": [
                1,
                1
            ],
            "MIN": [
                0.01,
                0.01
            ],
            "NAME": "circle8MinMax",
            "TYPE": "point2D"
        }
    ],
    "ISFVSN": "2"
}
*/

const vec4 red = vec4(1., 0., 0., 1.);
const vec4 white = vec4(1., 1., 1., 1.);
const vec4 blue = vec4(0., 0., 1., 1.);

const float bpm = 125.0;
const vec2 shiftFactorX = vec2(0.5);
const vec2 shiftFactorY = vec2(0.5);
const float alpha = 1.0;
const vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);


float circle(vec2 st, float pct, float minLimit, float maxLimit) {
  return  smoothstep( pct - minLimit, pct, distance(st, vec2(shiftFactorX.x, shiftFactorY.y))) -
          smoothstep( pct, pct + maxLimit, distance(st, vec2(shiftFactorY.x, shiftFactorX.y)));
}

float fillCircle(vec2 st, float pct){
  return  step(0., distance(st,vec2(0.5))) -
          step( pct, distance(st,vec2(0.5)));
}

float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

void main() {
    vec2 st = (gl_FragCoord.xy-.5*RENDERSIZE.xy)/RENDERSIZE.y+.5;

    float bbpm = 4.;  // beats per measure
    float spm = (bbpm*60./bpm)/4.; // seconds per measure

    float time = TIME;

    float drawCircle1 = map(sin(TIME / spm), -1., 1., 0.40, 0.45);
    float drawCircle2 = map(sin(TIME / spm), -1., 1., 0.35, 0.39);
    float drawCircle3 = map(sin(TIME / spm), -1., 1., 0.30, 0.34);
    float drawCircle4 = map(sin(TIME / spm), -1., 1., 0.25, 0.29);
    float drawCircle5 = map(sin(TIME / spm), -1., 1., 0.20, 0.24);
    float drawCircle6 = map(sin(TIME / spm), -1., 1., 0.15, 0.19);
    float drawCircle7 = map(sin(TIME / spm), -1., 1., 0.10, 0.14);
    float drawCircle8 = map(sin(TIME / spm), -1., 1., 0.05, 0.09);
    
    vec3 circle1 = vec3(circle(st, drawCircle1, circle1MinMax.x, circle1MinMax.y));
    vec3 circle2 = vec3(circle(st, drawCircle2, circle2MinMax.x, circle2MinMax.y));
    vec3 circle3 = vec3(circle(st, drawCircle3, circle3MinMax.x, circle3MinMax.y));
    vec3 circle4 = vec3(circle(st, drawCircle4, circle4MinMax.x, circle4MinMax.y));
    vec3 circle5 = vec3(circle(st, drawCircle5, circle5MinMax.x, circle5MinMax.y));
    vec3 circle6 = vec3(circle(st, drawCircle6, circle6MinMax.x, circle6MinMax.y));
    vec3 circle7 = vec3(circle(st, drawCircle7, circle7MinMax.x, circle7MinMax.y));
    vec3 circle8 = vec3(circle(st, drawCircle8, circle8MinMax.x, circle8MinMax.y));

    vec4 color =  
        smoothstep(0.0, 1.0, vec4(circle1, alpha) * mix(red, white, 0.25)) +
        smoothstep(0.0, 1.0, vec4(circle2, alpha) * mix(white, blue, 0.25)) +
        smoothstep(0.0, 1.0, vec4(circle3, alpha) * mix(blue, red, 0.25)) +
        smoothstep(0.0, 1.0, vec4(circle4, alpha) * mix(red, white, 0.25)) +
        smoothstep(0.0, 1.0, vec4(circle5, alpha) * mix(white, blue, 0.25)) +
        smoothstep(0.0, 1.0, vec4(circle6, alpha) * mix(blue, red, 0.25)) + 
        smoothstep(0.0, 1.0, vec4(circle7, alpha) * mix(red, white, 0.25)) + 
        smoothstep(0.0, 1.0, vec4(circle8, alpha) * mix(white, blue, 0.25));

	color += backgroundColor;

    gl_FragColor = color;
}
