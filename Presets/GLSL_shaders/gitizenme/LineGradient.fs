/*{
    "CREDIT": "izenme",
    "INPUTS": [
        {
            "DEFAULT": 0,
            "LABEL": "Red",
            "MAX": 1,
            "MIN": 0,
            "NAME": "red",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "Green",
            "MAX": 1,
            "MIN": 0,
            "NAME": "green",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "Blue",
            "MAX": 1,
            "MIN": 0,
            "NAME": "blue",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.2,
            "NAME": "stepMinLeft",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "NAME": "stepMaxLeft",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "NAME": "stepMinRight",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.8,
            "NAME": "stepMaxRight",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.02,
            "NAME": "width",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/



float plot(vec2 st, float pct){
  return  smoothstep( pct-width, pct, st.y) -
          smoothstep( pct, pct+width, st.y);
}

void main() {
    vec2 st = isf_FragNormCoord;

//    float y = smoothstep(0.2,0.5,st.x) - smoothstep(0.5,0.8,st.x);
    float y = smoothstep(stepMinLeft,stepMaxLeft,st.x) - smoothstep(stepMinRight,stepMaxRight,st.x);
//    float y = smoothstep(0.1,0.9,st.x);

    vec3 color = vec3(y);

    float pct = plot(st,y);
    color = (1.0-pct)*color+pct*vec3(red,green,blue);

    gl_FragColor = vec4(color,1.0);
}