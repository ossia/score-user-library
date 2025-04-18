/*{
	"CREDIT" : "AcidAtTheDisco by Author",
	"CATEGORIES" : [
		"ci"
		], 
	"DESCRIPTION": "https://www.shadertoy.com/view/4sfXRB",
	"INPUTS": [
		{
			"NAME" :"iMouse",
			"TYPE" : "point2D",
			"DEFAULT" : [0.0, 0.0],
			"MAX" : [640.0, 480.0],
			"MIN" : [0.0, 0.0]
		}
	]
}*/
	// https://www.shadertoy.com/view/4sfXRB
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{ fragColor = vec4(0., 0., 0., 1.);
	vec2 uv = fragCoord.xy / RENDERSIZE.xy;
	float time = TIME;
	float depth = sin(uv.y*2.0+sin(time)*1.5+1.0+sin(uv.x*3.0+time*1.2))*cos(uv.y*2.0+time)+sin((uv.x*3.0+time));
	float texey = (uv.x-0.5);
	float xband = sin(sqrt(uv.y/uv.y)*16.0/(depth)+time*3.0);
	float final = (
		sin(texey/abs(depth)*32.0+time*16.0+sin(uv.y*uv.x*32.0*sin(depth*3.0)))*(depth)*xband
	);

	
	fragColor = vec4(-final*abs(sin(time)),(-final*sin(time)*2.0),(final),1.0)*1.5;
}
void main(void) { mainImage(gl_FragColor, gl_FragCoord.xy); }