/*
{
  "CATEGORIES" : [
    "Automatically Converted",
    "GLSLSandbox"
  ],
  "INPUTS" : [

  ],
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#47635.0"
}
*/


#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable


void main( void ) {

	vec2 p = ( gl_FragCoord.xy * 2.0 - RENDERSIZE) / min(RENDERSIZE.x,RENDERSIZE.y);
	vec3 destColor = vec3(0.0,0.2,1.0);
	float f = 0.0;
	for ( float i = 0.0; i < 500.0; i++){
		float s = sin(TIME*3.0 + i * 0.0031415926) * 0.8;
		float c = cos(TIME*2.0+i *0.0031415926)*0.8;
		f += 0.00001/abs(length(p+vec2(c,s))-i/500000.)*(pow(i,2.0)/1000.0);
	}
	
	gl_FragColor = vec4(vec3(destColor*f),1.0);	
}		