/*
{
  "CATEGORIES" : [
    "Automatically Converted"
  ],
  "INPUTS" : [

  ],
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#36477.0"
}
*/


//---　houndstooth ---
// by Catzpaw 2016
// DESTROYED BY TH∀UM∀TIN

#ifdef GL_ES
precision mediump float;
#endif


#extension GL_OES_standard_derivatives : enable

#define PITCH .005
#define CORRECTION 960.

#define ttime sin(TIME+gl_FragCoord.y/400.)

void main(void){
	vec2 p=floor(gl_FragCoord.xy*PITCH*CORRECTION)/CORRECTION;
	gl_FragColor=vec4(vec3(clamp(
		step(mod(cos(p.x-ttime)+cos(p.y+ttime)    ,.5),.25)*step(mod(p.x-ttime,0.1),1.5)-
		step(mod(cos(p.x+ttime)+cos(p.y*ttime)+.25,.5),.25)*step(mod(p.y+ttime,.1),1.5),
		0.,sin((ttime-gl_FragCoord.x/10.)*100.))),1);
}