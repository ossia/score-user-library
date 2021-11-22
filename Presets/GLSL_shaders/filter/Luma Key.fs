/*{
	"DESCRIPTION": "Luma Key FX",
	"CREDIT": "by IMIMOT (ported from http://www.memo.tv/)",
	"CATEGORIES": [
		"Masking"
	],
	"INPUTS": [
		{
			"NAME": "inputImage",
			"TYPE": "image"
		},
		{
			"NAME": "threshold",
			"TYPE": "float",
			"DEFAULT": 0.0,
			"MIN": 0.00,
			"MAX": 1.0
		},
		{
			"NAME": "softness",
			"TYPE": "float",
			"DEFAULT": 0.0,
			"MIN": 0.00,
			"MAX": 1.0
		}
		
	]
}*/

void main()
{
	vec4 pix = IMG_THIS_NORM_PIXEL(inputImage);
	float fValue = (pix.r *0.29+ pix.g*0.6 + pix.b*0.11);
	float l1 = threshold - softness * 0.5;
	float l2 = l1 + softness;
	fValue = smoothstep(max(l1,0.0), min(l2, 1.0), fValue);
	pix.a = fValue;
     
    // final mix needed to make alpha working
    gl_FragColor = mix(vec4(0.0),pix,pix.a);
  
}
