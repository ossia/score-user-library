/*{
    "CATEGORIES": [
        "XXX"
    ],
    "CREDIT": "",
    "INPUTS": [
        {
            "NAME": "red",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "NAME": "green",
            "TYPE": "float"
        },
        {
            "NAME": "blue",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "NAME": "alpha",
            "TYPE": "float"
        },
        {
            "NAME": "centerX",
            "TYPE": "float"
        },
        {
            "NAME": "centerY",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/



void main() {
  vec2 st = isf_FragNormCoord;
  st.x *= RENDERSIZE.x/RENDERSIZE.y;
  vec3 color = vec3(0.0);
  float d = 0.0;

  // Remap the space to -1. to 1.
  st = st *2.-1.;

  // Make the distance field
  d = length( abs(st)-.3 );
  // d = length( min(abs(st)-.3,0.) );
  // d = length( max(abs(st)-.3,0.) );

  // Visualize the distance field
  vec3 colorIn = vec3(fract(d*10.0));
  colorIn.r = red;
  //colorIn.g = green;
  colorIn.b = blue;
  gl_FragColor = vec4(colorIn, alpha);

  // Drawing with the distance field
  // gl_FragColor = vec4(vec3( step(.3,d) ),1.0);
  // gl_FragColor = vec4(vec3( step(.3,d) * step(d,.4)),1.0);
  // gl_FragColor = vec4(vec3( smoothstep(.3,.4,d)* smoothstep(.6,.5,d)) ,1.0);
}