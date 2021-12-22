/*{
  "DESCRIPTION": "Pixels update only if within range of the specified lines to create a slit scan style",
  "CREDIT": "by VIDVOX",
  "CATEGORIES": [
    "Glitch"
  ],
  "INPUTS": [
    {
      "NAME": "inputImage",
      "TYPE": "image"
    },
    {
      "NAME": "spacing",
      "TYPE": "float",
      "MIN": 0,
      "MAX": 1.5,
      "DEFAULT": 1
    },
    {
      "NAME": "line_width",
      "TYPE": "float",
      "MIN": 0,
      "MAX": 1,
      "DEFAULT": 0.05
    },
    {
      "NAME": "angle",
      "TYPE": "float",
      "MIN": -1,
      "MAX": 1,
      "DEFAULT": 0.0
    },
    {
      "NAME": "autoshift",
      "TYPE": "bool",
      "DEFAULT": 1
    },
    {
      "NAME": "shift",
      "TYPE": "float",
      "MIN": 0,
      "MAX": 1,
      "DEFAULT": 0.5
    }
  ],
  "PASSES": [
    {
      "TARGET": "bufferVariableNameA",
      "PERSISTENT": true
    }
  ]
}*/


const float pi = 3.14159265359;


float pattern() {
	float s = sin(angle * pi);
	float c = cos(angle * pi);
	vec2 tex = isf_FragNormCoord * RENDERSIZE;
	float spaced = length(RENDERSIZE) * spacing;
	vec2 point = vec2( c * tex.x - s * tex.y, s * tex.x + c * tex.y ) * max(1.0/spaced,0.001);
	float d = point.y;
	float w = line_width;
	if (w > spacing)	{
		w = 0.99*spacing;
	}
	float localShift = (autoshift) ? mod(TIME*0.25,1.0) : shift;
	return ( mod(d + localShift*spacing + w * 0.5,spacing) );
}

void main()
{
	vec4	freshPixel = IMG_PIXEL(inputImage,gl_FragCoord.xy);
	//	If we're on the line, update, otherwise use the stale pixel
	vec4 	result = IMG_PIXEL(bufferVariableNameA,gl_FragCoord.xy);
	float pat = pattern();
	float w = line_width;
	if (w > spacing)	{
		w = 0.99*spacing;
	}

	if ((pat > 0.0)&&(pat <= w))	{
		float percent = (1.0-abs(w-2.0*pat)/w);
		percent = clamp(percent,0.0,1.0);
		result = mix(result, freshPixel, percent);
		//result = vec4(percent,percent,percent,1.0);
	}
	gl_FragColor = result;
}
