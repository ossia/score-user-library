/*
{
  "CATEGORIES" : [
    "Halftone Effect"
  ],
  "ISFVSN" : "2",
  "INPUTS" : [
    {
      "NAME" : "inputImage",
      "TYPE" : "image"
    },
    {
      "NAME" : "sharpness",
      "TYPE" : "float",
      "MAX" : 10,
      "DEFAULT" : 1,
      "MIN" : 0
    },
    {
      "NAME" : "angle",
      "TYPE" : "float",
      "MAX" : 1,
      "DEFAULT" : 0,
      "MIN" : 0
    },
    {
      "NAME" : "scale",
      "TYPE" : "float",
      "MAX" : 2,
      "DEFAULT" : 1,
      "MIN" : 0
    },
    {
      "NAME" : "colorize",
      "TYPE" : "float",
      "MAX" : 1,
      "DEFAULT" : 0,
      "MIN" : -1
    },
    {
      "NAME" : "divs",
      "TYPE" : "float",
      "MAX" : 16,
      "DEFAULT" : 4,
      "MIN" : 1
    },
    {
      "LABELS" : [
        "Random",
        "Dot",
        "Circular",
        "Line"
      ],
      "NAME" : "patternType",
      "TYPE" : "long",
      "DEFAULT" : 0,
      "VALUES" : [
        0,
        1,
        2,
        3
      ]
    }
  ],
  "CREDIT" : "by VIDVOX"
}
*/

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

const float tau = 6.28318530718;

vec3 rgb2hsv(vec3 c)	{
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	//vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	//vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)	{
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float dotScreenPattern(float ang, float sca, vec2 cent) {
	float s = sin( ang * tau ), c = cos( ang * tau );
	vec2 tex = isf_FragNormCoord * RENDERSIZE - cent * RENDERSIZE;
	vec2 point = vec2( c * tex.x - s * tex.y, s * tex.x + c * tex.y ) * max(sca,0.001);
	return ( sin( point.x ) * sin( point.y ) ) * 4.0;
}

float circleScreenPattern(float ang, float sca, vec2 cent) {
	float s = 0.0;
	float c = 1.0;
	vec2 tex = isf_FragNormCoord * RENDERSIZE;
	vec2 point = vec2( c * tex.x - s * tex.y, s * tex.x + c * tex.y );
	float d = distance(point, cent * RENDERSIZE) * max(sca,0.001);
	return ( sin(d + ang * tau) ) * 4.0;
}

float lineScreenPattern(float ang, float sca, vec2 cent) {
	float s = sin(tau * ang * 0.5);
	float c = cos(tau * ang * 0.5);
	vec2 tex = isf_FragNormCoord * RENDERSIZE;
	vec2 point = vec2( c * tex.x - s * tex.y, s * tex.x + c * tex.y ) * max(sca,0.001);
	float d = point.y;

	return ( cent.x + sin(d + cent.y * tau) ) * 4.0;
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
	vec4 color = IMG_THIS_PIXEL(inputImage);
	vec4 colorL = IMG_NORM_PIXEL(inputImage, left_coord);
	vec4 colorR = IMG_NORM_PIXEL(inputImage, right_coord);
	vec4 colorA = IMG_NORM_PIXEL(inputImage, above_coord);
	vec4 colorB = IMG_NORM_PIXEL(inputImage, below_coord);

	vec4 colorLA = IMG_NORM_PIXEL(inputImage, lefta_coord);
	vec4 colorRA = IMG_NORM_PIXEL(inputImage, righta_coord);
	vec4 colorLB = IMG_NORM_PIXEL(inputImage, leftb_coord);
	vec4 colorRB = IMG_NORM_PIXEL(inputImage, rightb_coord);

	vec4 final = color + sharpness * (8.0*color - colorL - colorR - colorA - colorB - colorLA - colorRA - colorLB - colorRB);
	vec3 hsv = rgb2hsv(final.rgb);
	float ang = floor(hsv.r * divs + 0.5) / divs;
	float sca = floor(hsv.b * divs + 0.5) / divs;
	float col = max(min(colorize + floor(hsv.g * divs + 0.5) / divs,1.0),0.0);;

	float average = ( final.r + final.g + final.b ) / 3.0;
	int pType = patternType;
	if (pType == 0)	{
		pType = int(2.9999 * rand(vec2(ang,sca)));
	}
	else	{
		pType = pType - 1;
	}
	if (pType == 0)	{
		final = vec4( vec3( average * 10.0 - 5.0 + dotScreenPattern(angle + ang, scale * sca, vec2(0.5)) ), color.a );
	}
	else if (pType == 1)	{
		final = vec4( vec3( average * 10.0 - 5.0 + circleScreenPattern(angle + ang, scale * sca, vec2(0.5)) ), color.a );
	}
	else if (pType == 2)	{
		final = vec4( vec3( average * 10.0 - 5.0 + lineScreenPattern(angle + ang, scale * sca, vec2(0.5)) ), color.a );
	}

	final = mix (color * final, final, 1.0-col);
	gl_FragColor = final;
}

