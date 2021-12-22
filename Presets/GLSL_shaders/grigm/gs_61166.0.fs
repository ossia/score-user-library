/*
{
  "CATEGORIES" : [
    "Automatically Converted",
    "GLSLSandbox"
  ],
  "INPUTS" : [

  ],
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#61166.0"
}
*/


//precision highp float;



float speed = 0.1750;

float ball(vec2 p, float fx, float fy, float ax, float ay)
{
	vec2 r = vec2(p.x + sin(TIME*speed / 2.0 * fx) * ax * 4.0, p.y + cos(TIME*speed/ 2.0 * fy) * ay * 4.0);	
	return .027 / length(r / sin(fy * TIME * 0.1));
}

void main(void)
{
	vec2 p = ( gl_FragCoord.xy / RENDERSIZE.xy ) * 2.0 - 1.0;
	p.x *= RENDERSIZE.x / RENDERSIZE.y;
	
	float col = 0.0 ,col2 = 0.0;
	col += ball(p, 31.0, 22.0, 0.03, 0.09);
	col += ball(p, 22.5, 22.5, 0.04, 0.04);
	col += ball(p, 12.0, 23.0, 0.05, 0.03);
	col += ball(p, 32.5, 33.5, 0.06, 0.04);
	col += ball(p, 23.0, 24.0, 0.07, 0.03);	
	col += ball(p, 21.5, 22.5, 0.08, 0.02);
	col += ball(p, 33.1, 21.5, 0.09, 0.07);
	col += ball(p, 23.5, 32.5, 0.09, 0.06);
	col += ball(p, 14.1, 13.5, 0.09, 0.05);
	
	col2 += ball(p, 22.0, 27.0, 0.03, 0.05);
	col2 += ball(p, 12.5, 17.5, 0.04, 0.06);
	col2 += ball(p, 23.0, 17.0, 0.05, 0.02);
	col2 += ball(p, 19.5, 23.5, 0.06, 0.09);
	col2 += ball(p, 33.0, 14.0, 0.07, 0.01);	
	col2 += ball(p, 11.5, 12.5, 0.08, 0.04);
	col2 += ball(p, 23.1, 11.5, 0.09, 0.07);
	col2 += ball(p, 13.5, 22.5, 0.09, 0.03);
	col2 += ball(p, 14.1, 23.5, 0.09, 0.08);
	
	gl_FragColor = vec4(pow(col * 0.54 * col2,3.0/col), col * 0.34, col2 * 0.9 * sin(TIME), 1.0) + vec4(col2 * 0.33, col * col2 * 0.24 * cos(TIME),col2*0.9,1.0);
}