/*
{
  "CATEGORIES" : [
    "Automatically Converted",
    "GLSLSandbox"
  ],
  "INPUTS" : [

  ],
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#46597.1"
}
*/


#ifdef GL_ES
precision mediump float;
#endif

//from https://www.shadertoy.com/view/4dl3zn

void main( void ) {

	vec2 uv = -1.0 + 2.0*isf_FragNormCoord;
	uv.x *=  RENDERSIZE.x / RENDERSIZE.y;

    // background	 
	vec3 color = vec3(0.8 + 0.2*uv.y);

    // bubbles	
	for( int i=0; i<40; i++ )
	{
        // bubble seeds
		float pha =      sin(float(i)*546.13+1.0)*0.5 + 0.5;
		float siz = pow( sin(float(i)*651.74+5.0)*0.5 + 0.5, 4.0 );
		float pox =      sin(float(i)*321.55+4.1) * RENDERSIZE.x / RENDERSIZE.y;

        // buble size, position and color
		float rad = 0.1 + 0.5*siz;
		vec2  pos = vec2( pox, -1.0-rad + (2.0+2.0*rad)*mod(pha+0.1*TIME*(0.2+0.8*siz),1.0));
		float dis = length( uv - pos );
		vec3  col = mix( vec3(0.94,0.3,0.0), vec3(0.1,0.4,0.8), 0.5+0.5*sin(float(i)*1.2+1.9));
		//    col+= 8.0*smoothstep( rad*0.95, rad, dis );
		
        // render
		float f = length(uv-pos)/rad;
		f = sqrt(clamp(1.0-f*f,0.0,1.0));
		color -= col.zyx *(1.0-smoothstep( rad*0.95, rad, dis )) * f;
	}

    // vigneting	
	color *= sqrt(1.5-0.5*length(uv));

	gl_FragColor = vec4(color,1.0);
}