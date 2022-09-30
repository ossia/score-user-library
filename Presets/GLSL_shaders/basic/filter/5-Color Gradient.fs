/*{
  "CREDIT": "by INKA",
  "CATEGORIES": [
    "Color Effect",
    "INKA"
  ],
  "INPUTS": [
    {
      "NAME": "inputImage",
      "TYPE": "image"
    },
    {
      "LABEL": "Color 1",
      "NAME": "color_1",
      "TYPE": "color",
      "DEFAULT": [
        0,
        0,
        0,
        1
      ]
    },
    {
      "LABEL": "Color 2",
      "NAME": "color_2",
      "TYPE": "color",
      "DEFAULT": [
        0,
        0.25,
        0,
        1
      ]
    },
    {
      "LABEL": "Color 3",
      "NAME": "color_3",
      "TYPE": "color",
      "DEFAULT": [
        0.54,
        0.07,
        0,
        1
      ]
    },
    {
      "LABEL": "Color 4",
      "NAME": "color_4",
      "TYPE": "color",
      "DEFAULT": [
        0.75,
        0.8,
        0,
        1
      ]
    },
    {
      "LABEL": "Color 5",
      "NAME": "color_5",
      "TYPE": "color",
      "DEFAULT": [
        0,
        0,
        0,
        1
      ]
    }
  ]
}*/


//	adapted from vidvox's thermal vision effect

#if __VERSION__ <= 120
varying vec2 left_coord;
varying vec2 right_coord;
varying vec2 above_coord;
varying vec2 below_coord;

varying vec2 lefta_coord;
varying vec2 righta_coord;
varying vec2 leftb_coord;
varying vec2 rightb_coord;
#else
in vec2 left_coord;
in vec2 right_coord;
in vec2 above_coord;
in vec2 below_coord;

in vec2 lefta_coord;
in vec2 righta_coord;
in vec2 leftb_coord;
in vec2 rightb_coord;
#endif


void main ()	{
	
	vec4 color = IMG_THIS_NORM_PIXEL(inputImage);
	vec4 colorL = IMG_NORM_PIXEL(inputImage, left_coord);
	vec4 colorR = IMG_NORM_PIXEL(inputImage, right_coord);
	vec4 colorA = IMG_NORM_PIXEL(inputImage, above_coord);
	vec4 colorB = IMG_NORM_PIXEL(inputImage, below_coord);

	vec4 colorLA = IMG_NORM_PIXEL(inputImage, lefta_coord);
	vec4 colorRA = IMG_NORM_PIXEL(inputImage, righta_coord);
	vec4 colorLB = IMG_NORM_PIXEL(inputImage, leftb_coord);
	vec4 colorRB = IMG_NORM_PIXEL(inputImage, rightb_coord);

	vec4 avg = (color + colorL + colorR + colorA + colorB + colorLA + colorRA + colorLB + colorRB) / 9.0;
	
	//float lum = (avg.r+avg.g+avg.b)/3.0;
	float lum = dot(vec3(0.30, 0.59, 0.11), avg.rgb);
	lum = pow(lum,1.4);

	int ix = 0;
	float range = 1.0 / 5.0;
	
	//	orange to red
	vec4 startColor;
	vec4 endColor;
	
	//	cyan to green
	if (lum > range * 3.0)	{
		startColor = color_4;
		endColor = color_5;
		ix = 3;
	}
	//	blue to cyan
	else if (lum > range * 2.0)	{
		startColor = color_3;
		endColor = color_4;
		ix = 2;
	}
	// purple to blue
	else if (lum > range)	{
		startColor = color_2;
		endColor = color_3;
		ix = 1;
	}
	else	{
		startColor = color_1;
		endColor = color_2;
	}

	vec4 thermal = mix(startColor,endColor,(lum - float(ix) * range)/range);
	gl_FragColor = thermal;

}
