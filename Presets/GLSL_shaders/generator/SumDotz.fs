/*{
	"CREDIT": "by mojovideotech",
	"DESCRIPTION": "",
	"CATEGORIES": [
		"generator"
	],
	"INPUTS": [
	{
		"NAME" : 		"scale",
		"TYPE" : 		"float",
		"DEFAULT" : 	0.025,
		"MIN" : 		0.01,
		"MAX" : 		0.1
	},
	{
		"NAME" : 		"rate",
		"TYPE" : 		"float",
		"DEFAULT" : 	0.5,
		"MIN" : 		-3.0,
		"MAX" : 		3.0
	},
	{
     	"NAME" :		"seed1",
     	"TYPE" : 		"float",
     	"DEFAULT" :		21,
     	"MIN" : 		13,
     	"MAX" :			233
	},
    {
      	"NAME" :		"seed2",
      	"TYPE" :		"float",
      	"DEFAULT" :		59,
      	"MIN" : 		5,
      	"MAX" :			198	
	},
	{
      	"NAME" :		"delta",
      	"TYPE" :		"float",
      	"DEFAULT" :		0.025,
      	"MIN" : 		0.001,
      	"MAX" :			0.99	
	}
	]
}*/

////////////////////////////////////////////////////////////
// SumDotz  by mojovideotech
//
// based on :
// shadertoy.com/view/Xllcz7
//
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0
////////////////////////////////////////////////////////////


void main() 
{
	vec4 col = vec4(0.0);
	float z = (0.11-scale)*1000.;
	vec2 st = vec2(gl_FragCoord.xy/RENDERSIZE.x*z);		
	float T = TIME*rate;
    st.y += T;									
    col += smoothstep(.6,.71-scale,1.05-length(fract(st)-.5))*fract(sin(dot(ceil(st)/z,vec2(seed1,seed2)))/(TIME/delta)*4e5);
	gl_FragColor = vec4(col);
}

