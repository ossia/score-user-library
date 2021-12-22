/*
{
  "CATEGORIES" : [
    "icalvin102"
  ],
  "DESCRIPTION" : "Creates a BW image from RGB",
  "ISFVSN" : "2",
  "INPUTS" : [
    {
      "NAME" : "inputImage",
      "TYPE" : "image"
    },
    {
      "NAME" : "factor",
      "TYPE" : "color",
      "DEFAULT" : [
        0.5,
        0.5,
        0.5,
        1
      ],
      "LABEL" : "Mix Factor"
    }
  ],
  "PASSES" : [
    {
      "DESCRIPTION" : "Renderpass 0"
    }
  ],
  "CREDIT" : "icalvin102 (calvin@icalvin.de)"
}
*/

float channelmix(vec3 c, vec3 f){
	c *= f;
	return c.r+c.g+c.b;
}

void main()	{
	vec4		inputPixelColor;
	inputPixelColor = IMG_THIS_PIXEL(inputImage);
	float c = channelmix(inputPixelColor.rgb, factor.rgb);

	gl_FragColor = vec4(vec3(c), inputPixelColor.a);
}
