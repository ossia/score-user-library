/*
{
  "CATEGORIES" : [
    "Film",
    "Masking"
  ],
  "DESCRIPTION" : "Value Noise",
  "INPUTS" : [
    {
      "NAME" : "inputImage",
      "TYPE" : "image"
    },
    {
      "NAME" : "scale",
      "TYPE" : "float",
      "MAX" : 100,
      "DEFAULT" : 9,
      "MIN" : 0,
      "LABEL" : "Dirt Size"
    },
    {
      "NAME" : "brightness",
      "TYPE" : "float",
      "MAX" : 4,
      "DEFAULT" : 0.5,
      "MIN" : 0,
      "LABEL" : "Dirt Thickness"
    },
    {
      "NAME" : "brightnessCurve",
      "TYPE" : "float",
      "MAX" : 4,
      "DEFAULT" : 1,
      "LABEL" : "Dirt Shape",
      "MIN" : 1
    },
    {
      "NAME" : "radius",
      "TYPE" : "float",
      "MAX" : 1,
      "DEFAULT" : 0.5,
      "LABEL" : "Dirt Spread",
      "MIN" : 0
    },
    {
      "NAME" : "noiseSeed",
      "TYPE" : "float",
      "MAX" : 1,
      "DEFAULT" : 0,
      "MIN" : 0,
      "LABEL" : "Dirt Seed"
    },
    {
      "LABELS" : [
        "Original",
        "Multiply",
        "Replace"
      ],
      "NAME" : "alphaMode",
      "TYPE" : "long",
      "IDENTITY" : 0,
      "LABEL" : "Alpha Mode",
      "VALUES" : [
        0,
        1,
        2
      ]
    }
  ],
  "ISFVSN" : "2",
  "CREDIT" : "Inigo Quilez ported by @colin_movecraft and VIDVOX"
}
*/



// Value Noise (http://en.wikipedia.org/wiki/Value_noise), not to be confused with Perlin's
// Noise, is probably the simplest way to generate noise (a random smooth signal with 
// mostly all its energy in the low frequencies) suitable for procedural texturing/shading,
// modeling and animation.
//
// It produces lowe quality noise than Gradient Noise (https://www.shadertoy.com/view/XdXGW8)
// but it is slightly faster to compute. When used in a fractal construction, the blockyness
// of Value Noise gets qcuikly hidden, making it a very popular alternative to Gradient Noise.
//
// The princpiple is to create a virtual grid/latice all over the plane, and assign one
// random value to every vertex in the grid. When querying/requesting a noise value at
// an arbitrary point in the plane, the grid cell in which the query is performed is
// determined (line 30), the four vertices of the grid are determined and their random
// value fetched (lines 35 to 38) and then bilinearly interpolated (lines 35 to 38 again)
// with a smooth interpolant (line 31 and 33).


// Value    Noise 2D, Derivatives: https://www.shadertoy.com/view/4dXBRH
// Gradient Noise 2D, Derivatives: https://www.shadertoy.com/view/XdXBRH
// Value    Noise 3D, Derivatives: https://www.shadertoy.com/view/XsXfRH
// Gradient Noise 3D, Derivatives: https://www.shadertoy.com/view/4dffRH
// Value    Noise 2D             : https://www.shadertoy.com/view/lsf3WH
// Value    Noise 3D             : https://www.shadertoy.com/view/4sfGzS
// Gradient Noise 2D             : https://www.shadertoy.com/view/XdXGW8
// Gradient Noise 3D             : https://www.shadertoy.com/view/Xsl3Dl
// Simplex  Noise 2D             : https://www.shadertoy.com/view/Msf3WH


float hash(vec2 p)  // replace this by something better
{
    p  = 50.0*fract(noiseSeed + p*0.3183099 + vec2(0.71,0.113));
    return -1.0+2.0*fract( p.x*p.y*(p.x+p.y) );
}

float noise( in vec2 p )
{
    vec2 i = floor( p );
    vec2 f = fract( p );
	
	vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( hash( i + vec2(0.0,0.0) ), 
                     hash( i + vec2(1.0,0.0) ), u.x),
                mix( hash( i + vec2(0.0,1.0) ), 
                     hash( i + vec2(1.0,1.0) ), u.x), u.y);
}

float map(float n, float i1, float i2, float o1, float o2){
	return o1 + (o2-o1) * (n-i1)/(i2-i1);
	
}

void main(){
    vec2 p = isf_FragNormCoord;

	vec2 uv = p*vec2(RENDERSIZE.x/RENDERSIZE.y,1.0);
	float f = 0.0;

	//fbm - fractal noise (4 octaves)	
	{
		uv *= scale;
        mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );
		f  = 0.5000*noise( uv ); uv = m*uv;
		f += 0.2500*noise( uv ); uv = m*uv;
		f += 0.1250*noise( uv ); uv = m*uv;
		f += 0.0625*noise( uv ); uv = m*uv;
	}
	
	f = 1.0-pow(f,(5.0-brightnessCurve))*brightness;
	
	float d = distance(isf_FragNormCoord,vec2(0.5));
	if (d > radius)	{
		f = f + (d-radius);
	}
	
	f = (f > 1.0) ? 1.0 : f;
	
	vec4 returnMe = IMG_THIS_PIXEL(inputImage) * vec4( f, f, f, 1.0 );
	if (alphaMode == 1)
		returnMe.a *= f;
	else if (alphaMode == 2)
		returnMe.a = f;
	gl_FragColor = returnMe;
}



// The MIT License
// Copyright © 2013 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
