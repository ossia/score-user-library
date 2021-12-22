/*{
    "CATEGORIES": [
        "XXX"
    ],
    "CREDIT": "",
    "INPUTS": [
        {
            "DEFAULT": 0.07,
            "NAME": "zoom",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "NAME": "rotation",
            "TYPE": "float"
        },
        {
            "DEFAULT": 20,
            "NAME": "orbs",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "NAME": "sinMul",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "NAME": "yMul",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "NAME": "xSpeed",
            "TYPE": "float"
        },
        {
            "DEFAULT": 4.99,
            "NAME": "yDivide",
            "TYPE": "float"
        },
        {
            "DEFAULT": 2.38,
            "NAME": "cosMul",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.28,
            "NAME": "xMul",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "NAME": "ySpeed",
            "TYPE": "float"
        },
        {
            "DEFAULT": 6.27,
            "NAME": "xDivide",
            "TYPE": "float"
        },
        {
            "DEFAULT": 11,
            "NAME": "radius",
            "TYPE": "float"
        },
        {
            "DEFAULT": 10.32,
            "NAME": "colorShift",
            "TYPE": "float"
        },
        {
            "DEFAULT": 6.46,
            "NAME": "orbSize",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.13,
            "NAME": "contrast",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/


#define PI 3.141592
#define orbs 20.


vec4 orb(vec2 uv, float s, vec2 p, vec3 color, float c) {
  return pow(vec4(s / length(uv + p) * color, 1.), vec4(c));
}

mat2 rotate(float a) {
  return mat2(cos(a), -sin(a), sin(a), cos(a));
}

void main() {
  vec2 uv = (2. * gl_FragCoord.xy - RENDERSIZE.xy) / RENDERSIZE.y;
  uv *= zoom;
  uv /= dot(uv, uv);
  uv *= rotate(rotation * TIME / 10.);
  for (float i = 0.; i < orbs; i++) {
    uv.x += sinMul * sin(uv.y * yMul + TIME * xSpeed) + cos(uv.y / yDivide - TIME);
    uv.y += cosMul * cos(uv.x * xMul - TIME * ySpeed) - sin(uv.x / xDivide - TIME);
    float t = i * PI / orbs * 2.;
    float x = radius * tan(t);
    float y = radius * cos(t + TIME / 10.);
    vec2 position = vec2(x, y);
    vec3 color = cos(.02 * uv.x + .02 * uv.y * vec3(-2, 0, -1) * PI * 2. / 3. + PI * (float(i) / colorShift)) * 0.5 + 0.5;
    gl_FragColor += .65 - orb(uv, orbSize, position, 1. - color, contrast);
    gl_FragColor.a = 1.0;
  }
}