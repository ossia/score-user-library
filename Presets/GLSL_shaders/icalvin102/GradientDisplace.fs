/*
{
  "CATEGORIES" : [
    "icalvin102"
  ],
  "DESCRIPTION" : "!!!work in progress!!! Creates a 2D-Gradientvector from a greyscale image and displaces the inputImage along this vector",
  "ISFVSN" : "2",
  "INPUTS" : [
    {
      "NAME" : "inputImage",
      "TYPE" : "image"
    },
    {
      "NAME" : "displace",
      "TYPE" : "image"
    },
    {
      "NAME" : "amount",
      "TYPE" : "float",
      "MAX" : 5,
      "DEFAULT" : 0.01,
      "MIN" : 0
    },
    {
      "NAME" : "smooth",
      "TYPE" : "bool"
    }
  ],
  "PASSES" : [
    {
      "DESCRIPTION" : "Main"
    }
  ],
  "CREDIT" : "icalvin102 (calvin@icalvin.de)"
}
*/

void main()	{
	vec2 uv = isf_FragNormCoord.xy;
	vec3 e = vec3(1.0 / IMG_SIZE(displace).xy, 0.0);

	vec3 gx = IMG_NORM_PIXEL(displace, uv + e.xz).rgb - IMG_NORM_PIXEL(displace, uv - e.xz).rgb;
	vec3 gy = IMG_NORM_PIXEL(displace, uv + e.yz).rgb - IMG_NORM_PIXEL(displace, uv - e.yz).rgb;
	//gx /= 2.0*e.x;
	//gy /= 2.0*e.y;
	if(smooth){
		vec3 strength = IMG_NORM_PIXEL(displace, uv).rgb;
		gx *= strength;
		gy *= strength;
	}

	gx *= amount;
	gy *= amount;
	vec3 color = vec3(0.0);
	color.r = IMG_NORM_PIXEL(inputImage, uv + vec2(gx.r, gy.r)).r;
	color.g = IMG_NORM_PIXEL(inputImage, uv + vec2(gx.g, gy.g)).g;
	color.b = IMG_NORM_PIXEL(inputImage, uv + vec2(gx.b, gy.b)).b;
	gl_FragColor = vec4(color, 1.0);

}
