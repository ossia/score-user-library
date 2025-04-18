/*
{
  "CATEGORIES" : [
    "Automatically Converted",
    "GLSLSandbox"
  ],
  "INPUTS" : [

  ],
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#57722.0"
}
*/


#ifdef GL_ES
precision mediump float;
#endif



#define speed 2.0
#define freq 1.0
#define amp 0.1
#define phase 5.0


void main( void ) {

	vec2 p = ( isf_FragNormCoord ) - 0.2;
	
	float sx = (amp)*0.8 * sin( 10.0 * (freq) * (p.x-phase) - 5. * (speed)*TIME);
	
	float dy = 4./ ( 30. * abs(3.9*p.y - sx - 1.2));
	
	//dy += 1./ (60. * length(p - vec2(p.x, 0.)));
	
	gl_FragColor = vec4( (p.x + 0.4) * dy, 0.3 * dy, dy, 3.0 );

}