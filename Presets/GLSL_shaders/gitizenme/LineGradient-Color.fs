/*{
    "CREDIT": "",
    "INPUTS": [
        {
            "DEFAULT": 0.02,
            "NAME": "width",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                0.149,
                0.141,
                0.91,
                1
            ],
            "NAME": "colorA",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                1,
                0.833,
                0.224,
                1
            ],
            "NAME": "colorB",
            "TYPE": "color"
        }
    ],
    "ISFVSN": "2"
}
*/


const float pi = 3.14159265359;


vec3 colorAX = vec3(0.149,0.141,0.912);
vec3 colorBX = vec3(1.000,0.833,0.224);

float plot (vec2 st, float pct){
  return  smoothstep( pct-width, pct, st.y) -
          smoothstep( pct, pct+width, st.y);
}

void main() {
    vec2 st = isf_FragNormCoord;
    vec3 color = vec3(0.0);

    vec3 pct = vec3(st.x);

    // pct.r = smoothstep(0.0,1.0, st.x);
    // pct.g = sin(st.x*pi);
    // pct.b = pow(st.x,0.5);

    color = mix(vec3(colorA), vec3(colorB), pct);

    // Plot transition lines for each channel
    color = mix(color,vec3(1.0,0.0,0.0),plot(st,pct.r));
    color = mix(color,vec3(0.0,1.0,0.0),plot(st,pct.g));
    color = mix(color,vec3(0.0,0.0,1.0),plot(st,pct.b));

    gl_FragColor = vec4(color,1.0);
}