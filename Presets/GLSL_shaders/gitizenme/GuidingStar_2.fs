/*{
    "CATEGORIES": [
        "generator"
    ],
    "CREDIT": "Based on Guiding Star 2 by Silvia Fabiani https://editor.isf.video/shaders/5e7a7fd87c113618206de58e",
    "DESCRIPTION": "",
    "INPUTS": [
        {
            "DEFAULT": 0.7,
            "MAX": 1,
            "MIN": 0.2,
            "NAME": "blur",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1.57079632675,
            "MAX": 3.14159265359,
            "MIN": 0,
            "NAME": "rotationAngle",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.25,
            "MAX": 1,
            "MIN": 0.05,
            "NAME": "scale",
            "TYPE": "float"
        },
        {
            "DEFAULT": 120,
            "MAX": 240,
            "MIN": 0,
            "NAME": "bpm",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "MAX": 10,
            "MIN": 0.05,
            "NAME": "shine",
            "TYPE": "float"
        },
        {
            "DEFAULT": 2.5,
            "MAX": 10,
            "MIN": 0.05,
            "NAME": "beam",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "MAX": 10,
            "MIN": 0.05,
            "NAME": "magn",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.1,
            "MAX": 1,
            "MIN": 0,
            "NAME": "starRed",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.4,
            "MAX": 1,
            "MIN": 0,
            "NAME": "starGreen",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.9,
            "MAX": 1,
            "MIN": 0,
            "NAME": "starBlue",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                0,
                0
            ],
            "MAX": [
                0.05,
                0.05
            ],
            "MIN": [
                -0.05,
                -0.05
            ],
            "NAME": "pinchPoint",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                0,
                0
            ],
            "MAX": [
                0.5,
                0.5
            ],
            "MIN": [
                -0.5,
                -0.5
            ],
            "NAME": "center",
            "TYPE": "point2D"
        },
        {
            "NAME": "invert",
            "TYPE": "bool"
        }
    ],
    "ISFVSN": "2"
}
*/

#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.14159265359
#define HALF_PI 1.57079632675

mat2 rotate(float angle)
{
    return mat2( cos(angle),-sin(angle),sin(angle),cos(angle) );
}

void main(){
    vec2 st = (gl_FragCoord.xy-.5*RENDERSIZE.xy)/RENDERSIZE.y;
    vec3 color = vec3(0.0);

    st *= rotate(rotationAngle);

    float rate = bpm/60.0;

    float pinchY = sin (pinchPoint.y *TIME);
    float pinchX = sin (pinchPoint.x *TIME);
    float colorInvert = 1.0;

    if (invert) {
        colorInvert  = 2.0;
    }

    vec2 pos = vec2(center.x+st.x, center.y-st.y);

    float r = length(pos)/scale/2.0;
    float angle = atan((pos.y+pinchY),(pos.x+pinchX));

    float f = cos(angle*3.);
    f = abs(cos(angle/(shine/12.0)/rate)*sin(angle/(beam/8.0)/rate))*magn/rate+0.01;

    color += vec3( colorInvert -smoothstep(f,f+blur,r) );

    gl_FragColor = vec4(color, 1.0);
    gl_FragColor *= vec4(starRed, starGreen, starBlue, 1.0);

}

