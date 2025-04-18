/*
{
  "CATEGORIES" : [
    "Automatically Converted",
    "GLSLSandbox"
  ],
  "INPUTS" : [

  ],
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#31088.0"
}
*/


#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable


void main( void ) {

	vec2 uv = ( isf_FragNormCoord );
	
	float t = TIME * 0.8;
	float r = mod(t, 1.3) - 0.3;
	float w = 0.05;
	
	float ring = smoothstep(r, r+w,length(uv - 0.5)) - smoothstep(r + w, r + w * 2.0,length(uv - 0.5));
	
	uv *= 1.0 + ring * 0.15;
	
	vec2 p = mod(uv,0.1);
	float color = step(p.x, 0.01) + step(p.y, 0.01);
	gl_FragColor = vec4( color );

}