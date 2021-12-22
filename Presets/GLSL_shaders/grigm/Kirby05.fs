/*
{
  "CATEGORIES" : [
    "Generators"
  ],
  "DESCRIPTION" : "Kirby05",
  "ISFVSN" : "2",
  "VSN" : ".01",
  "INPUTS" : [
    {
      "NAME" : "u_input",
      "TYPE" : "image"
    },
    {
      "NAME" : "u_sourceThresh",
      "TYPE" : "float",
      "MAX" : 1,
      "DEFAULT" : 0,
      "MIN" : 0
    },
    {
      "NAME" : "u_previewBands",
      "TYPE" : "float",
      "MAX" : 3,
      "DEFAULT" : 0,
      "MIN" : 0
    },
    {
      "NAME" : "u_bands",
      "TYPE" : "float",
      "MAX" : 4,
      "DEFAULT" : 4,
      "MIN" : 2
    },
    {
      "NAME" : "u_wavePattern",
      "TYPE" : "bool",
      "DEFAULT" : true
    },
    {
      "NAME" : "u_waves",
      "TYPE" : "float",
      "MAX" : 2,
      "DEFAULT" : 0.63760650157928467,
      "MIN" : 0.10000000000000001
    },
    {
      "NAME" : "u_speed",
      "TYPE" : "float",
      "MAX" : 2,
      "DEFAULT" : 0.26469048857688904,
      "MIN" : 0
    },
    {
      "NAME" : "u_scale",
      "TYPE" : "float",
      "MAX" : 1,
      "DEFAULT" : -13.085433006286621,
      "MIN" : -20
    },
    {
      "NAME" : "u_scaleDiff",
      "TYPE" : "float",
      "MAX" : 5,
      "DEFAULT" : 2.2620737552642822,
      "MIN" : 0
    },
    {
      "NAME" : "u_density",
      "TYPE" : "float",
      "MAX" : 0,
      "DEFAULT" : -2.8055846691131592,
      "MIN" : -5
    },
    {
      "NAME" : "u_densityDiff",
      "TYPE" : "float",
      "MAX" : 1,
      "DEFAULT" : 0.23568330705165863,
      "MIN" : 0
    },
    {
      "NAME" : "u_offset",
      "TYPE" : "float",
      "MAX" : 1,
      "DEFAULT" : 0.038127988576889038,
      "MIN" : -1
    },
    {
      "NAME" : "u_overlap",
      "TYPE" : "float",
      "MAX" : 1,
      "DEFAULT" : 0.87262636423110962,
      "MIN" : 0
    },
    {
      "NAME" : "u_color1",
      "TYPE" : "color",
      "DEFAULT" : [
        0,
        0.090281277894973755,
        0.4900016188621521,
        1
      ]
    },
    {
      "NAME" : "u_color2",
      "TYPE" : "color",
      "DEFAULT" : [
        0.035999070852994919,
        0.58130508661270142,
        1,
        1
      ]
    },
    {
      "NAME" : "u_color3",
      "TYPE" : "color",
      "DEFAULT" : [
        1,
        0,
        0.46855348348617554,
        1
      ]
    },
    {
      "NAME" : "u_color4",
      "TYPE" : "color",
      "DEFAULT" : [
        1,
        0.034920874983072281,
        0,
        1
      ]
    }
  ],
  "CREDIT" : "Roger Sodre"
}
*/

// --------------------------
// FROM THE BOOK OF SHADERS

// Author: @patriciogv - 2015
// Title: Stippling

// Cellular noise ("Worley noise") in 2D in GLSL.
// Copyright (c) Stefan Gustavson 2011-04-19. All rights reserved.
// This code is released under the conditions of the MIT license.
// See LICENSE file for details.

// Permutation polynomial: (34x^2 + x) mod 289
vec4 permute(vec4 x) {
  return mod((34.0 * x + 1.0) * x, 289.0);
}

// Cellular noise, returning F1 and F2 in a vec2.
// Speeded up by using 2x2 search window instead of 3x3,
// at the expense of some strong pattern artifacts.
// F2 is often wrong and has sharp discontinuities.
// If you need a smooth F2, use the slower 3x3 version.
// F1 is sometimes wrong, too, but OK for most purposes.
vec2 cellular2x2(vec2 P) {
#define K 0.142857142857 // 1/7
#define K2 0.0714285714285 // K/2
#define jitter 0.8 // jitter 1.0 makes F1 wrong more often
	vec2 Pi = mod(floor(P), 289.0);
 	vec2 Pf = fract(P);
	vec4 Pfx = Pf.x + vec4(-0.5, -1.5, -0.5, -1.5);
	vec4 Pfy = Pf.y + vec4(-0.5, -0.5, -1.5, -1.5);
	vec4 p = permute(Pi.x + vec4(0.0, 1.0, 0.0, 1.0));
	p = permute(p + Pi.y + vec4(0.0, 0.0, 1.0, 1.0));
	vec4 ox = mod(p, 7.0)*K+K2;
	vec4 oy = mod(floor(p*K),7.0)*K+K2;
	vec4 dx = Pfx + jitter*ox;
	vec4 dy = Pfy + jitter*oy;
	vec4 d = dx * dx + dy * dy; // d11, d12, d21 and d22, squared
	// Sort out the two smallest distances
#if 0
	// Cheat and pick only F1
	d.xy = min(d.xy, d.zw);
	d.x = min(d.x, d.y);
	return d.xx; // F1 duplicated, F2 not computed
#else
	// Do it right and find both F1 and F2
	d.xy = (d.x < d.y) ? d.xy : d.yx; // Swap if smaller
	d.xz = (d.x < d.z) ? d.xz : d.zx;
	d.xw = (d.x < d.w) ? d.xw : d.wx;
	d.y = min(d.y, d.z);
	d.y = min(d.y, d.w);
	return sqrt(d.xy);
#endif
}



// --------------------------
// ROGER

#define QUARTERPI 0.785398163397448
#define HALFPI 1.57079632679489661923
#define PI 3.14159265358979323846
#define TWOPI 6.28318530717958647692

float GetBand(vec2 st, float src)
{
	float bandCount = floor(u_bands);
	float bandSize = 1.0 / bandCount;
	float band = floor(src/bandSize);
	return band;
}
float GetBandColor(float band)
{
	float bandCount = floor(u_bands);
	float bandColor = band * (1.0/(bandCount-1.0));
	return bandColor;
}
vec2 GetBandRange(float band, float overlap)
{
	float bandCount = floor(u_bands);
	float bandSize = (1.0/bandCount);
	float c1 = band * bandSize;
	float c2 = (band+1.0) * bandSize;
	if (band > 0.0)           c1 -= (bandSize * overlap);
	if (band < bandCount-1.0) c2 += (bandSize * overlap);
	return vec2(c1,c2);
}
float GetBandStep(vec2 range,float a)
{
	float bandStep = smoothstep( range.x, range.y, a );	// 0 .. 1
	if (range.y < 0.99)
	{
		bandStep = bandStep * 2.0 - 1.0;	// -1 .. 0 .. 1
		bandStep = 1.0 - abs(bandStep);		//  0 .. 1 .. 0
	}
	return bandStep;
}




// --------------------------
// MAIN
vec2 normalizedCoord(float r)
{
	vec2 st = (isf_FragNormCoord - 0.5) * 2.0 * r;
	st.x *= (RENDERSIZE.x/RENDERSIZE.y);
	return st;
}

void main(void) {
	vec2 st = normalizedCoord(1.0);
	vec3 source = vec3(isf_FragNormCoord.x);
	float src = source.x;
	
	vec3 tex = IMG_NORM_PIXEL(u_input, isf_FragNormCoord).xyz;
	float gray = (tex.x + tex.y + tex.z) / 3.0;
	float a = gray;
	
	if ( u_wavePattern)
	{
		a = dot(st,st)-TIME*u_speed;
		a = abs(sin(a*3.1415*u_waves));
		//a = abs(1.0 - cos(a*3.1415*u_waves));
		//a = abs(sin(mod(a*3.1415*u_waves,HALFPI)));
	}
//	if ( u_wobble > 0.0 )
//		a += abs(sin((TIME)*0.2*3.1415)) * u_wobble;
	
	vec3 color = vec3(0);
	
	// Apply bands
	// float bandCount = floor(u_bands);
	// for (float band = 0.0 ; band < u_bands ; band++)
	for (float band = 0.0 ; band < 4.0 ; band++)
	{
		// Bands
		//float band = GetBand(st,a);
		//float bandColor = GetBandColor(band);
		vec2 bandRange = GetBandRange( band, u_overlap );
		if ( a >= bandRange.x && a <= bandRange.y )
		{
			float bandStep = GetBandStep( bandRange, a );
			// Noise
			float dens = abs(u_density) - (band * u_densityDiff);
			float scale = abs(u_scale) - (band * u_scaleDiff);
			vec2 st2 = st + vec2(-u_offset*TIME) * (band+1.0);
			vec2 F = cellular2x2( st2 * scale );
			//float n = 1.0 - step( a, F.x*dens );
			float n = 1.0 - step( bandStep, F.x*dens );
	
			if ( band == 0.0 )	color = max(color, n * u_color1.xyz );
			if ( band == 1.0 )	color = max(color, n * u_color2.xyz );
			if ( band == 2.0 )	color = max(color, n * u_color3.xyz );
			if ( band > 2.0 )	color = max(color, n * u_color4.xyz );
		}
	}
	
	// source thresh
	float thresh = 1.0 - u_sourceThresh;
	if ( gray >= thresh+0.1 )
		color = tex;
	else if ( gray >= thresh )
		color = vec3(1.0);
	
	if (u_previewBands > 0.0)
	{
		float band = GetBand(st,a);
		float bandColor = GetBandColor( band );
		vec2 bandRange = GetBandRange( band, u_overlap );
		float bandStep = GetBandStep( bandRange, a );
		if (floor(u_previewBands) == 1.0) color = vec3(a);
		if (floor(u_previewBands) == 2.0) color = vec3(bandColor);
		if (floor(u_previewBands) == 3.0) color = vec3(bandStep,bandStep,bandStep);
	}

	gl_FragColor = vec4(color, 1.0);
}
