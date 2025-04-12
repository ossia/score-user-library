/*{
	"DESCRIPTION": "",
	"CREDIT": "SilviaFabiani",
	"ISFVSN": "2",
	"CATEGORIES": [
		"generator"
	],
	"INPUTS": [
	{
      "NAME" : "BLUE",
      "TYPE" : "float",
      "MAX" : 1.0,
      "DEFAULT" : 1.0,
      "MIN" : 0.0
          },
          {
      "NAME" : "Shift",
      "TYPE" : "float",
      "MAX" : 1.0,
      "DEFAULT" : 0.5,
      "MIN" : 0.0
          },
          {
      "NAME": "pinchPoint",
      "TYPE": "point2D",
      "DEFAULT": [
        0,
        0
      ],
      "MIN": [
        -1,
        -1
      ],
      "MAX": [
        1,
        1
      ]
    }
		]
}*/

#ifdef GL_ES
precision mediump float;
#endif
float tempo = sin (TIME/3.); 
float loco = cos (TIME/0.5);
float magn = sin (TIME);
float growing = cos (TIME);
float RED = (sin (TIME+1.0)) ;
float GREEN = (cos (TIME-1.0)) ;

void main(){
    vec2 st = isf_FragNormCoord;
    vec3 color = vec3(0.0);

    vec2 pos = vec2(Shift)-st ;

    float r = length(pos*magn)*0.95;
    float a = atan(pos.y+(tempo*pinchPoint.y),pos.x+(tempo*pinchPoint.x));

    float f = cos(a*3.);
    
    f = abs(cos(a*12.560*tempo*2.0)*sin(a*4.088))*growing +-(0.276);
    
    color = vec3( 1.-smoothstep((1.8*f),f+0.9,r ) );

    gl_FragColor = vec4(color, 1.0);
    gl_FragColor.b *= BLUE;
	gl_FragColor.g *= GREEN;
	gl_FragColor.r *= RED;
}

