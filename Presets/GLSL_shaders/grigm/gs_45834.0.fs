/*
{
  "CATEGORIES" : [
    "Automatically Converted",
    "GLSLSandbox"
  ],
  "INPUTS" : [

  ],
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#45834.0"
}
*/


#ifdef GL_ES
precision mediump float;
#endif




	void main()
	{
		
		vec2 uv = (isf_FragNormCoord)-.5;
	
		float TIME = -TIME * .1 + ((.25+.05*sin(TIME*.1))/(length(uv.xy)+.07))* 2.2;
		float si = sin(TIME);
		float co = cos(TIME);
		mat2 ma = mat2(co, si, -si, co);
	
		float c = 0.0;
		float v1 = 0.0;
		float v2 = 0.0;
		
		for (int i = 0; i < 80; i++)
		{
			float s = float(i) * .035;
			vec3 p = s * vec3(uv, 0.0);
			p.xy *= ma;
			p += vec3(.22,.3, s-1.5-sin(TIME*.13)*.1);
			for (int i = 0; i < 4; i++)
			{
				p = abs(p) / dot(p,p) - 0.659;
			}
			v1 += dot(p,p)*.0015 * (1.8+sin(length(uv.xy*13.0)+.5-TIME*.2));
			v2 += dot(p,p)*.0015 * (1.5+sin(length(uv.xy*13.5)+2.2-TIME*.3));
			c = length(p.xy*.5) * .35;
		}
		
		float len = length(uv);
		v1 *= smoothstep(.7, .0, len);
		v2 *= smoothstep(.6, .0, len);
		
		float re = clamp(c, 0.0, 1.0);
		float gr = clamp((v1+c)*.25, 0.0, 1.0);
		float bl = clamp(v2, 0.0, 1.0);
		vec3 col = vec3(re, gr, bl) + smoothstep(0.15, .0, len) * .9;
	
		gl_FragColor=vec4(col, 1.0);
	}