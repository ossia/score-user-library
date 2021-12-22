/*{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/Ml3fWj by iq.  A technique used to generate new types of primitives in an exact way - without breaking the metric or introducing distortions to the field. More info here: [url]http://iquilezles.org/www/articles/distfunctions/distfunctions.htm[/url]",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": [
                0.1,
                0,
                0,
                1
            ],
            "LABEL": "Shape Color",
            "MAX": 1,
            "MIN": 0,
            "NAME": "shapeColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                1,
                0,
                1,
                1
            ],
            "LABEL": "Diffuse Color",
            "MAX": 1,
            "MIN": 0,
            "NAME": "diffColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0.5,
                0.54,
                0.2,
                1
            ],
            "LABEL": "Light Color",
            "MAX": 1,
            "MIN": 0,
            "NAME": "lightColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": 0.4,
            "LABEL": "lenX",
            "MAX": 1,
            "MIN": 0,
            "NAME": "lenX",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.2,
            "LABEL": "lenY",
            "MAX": 0.56,
            "MIN": 0,
            "NAME": "lenY",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.1,
            "LABEL": "lenZ",
            "MAX": 0.55,
            "MIN": 0,
            "NAME": "lenZ",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "pos1X",
            "MAX": 3,
            "MIN": -3,
            "NAME": "pos1X",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "pos1Y",
            "MAX": 3,
            "MIN": -3,
            "NAME": "pos1Y",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "pos2X",
            "MAX": 3,
            "MIN": -3,
            "NAME": "pos2X",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "pos2Y",
            "MAX": 3,
            "MIN": -3,
            "NAME": "pos2Y",
            "TYPE": "float"
        },
        {
            "DEFAULT": -1,
            "LABEL": "pos3X",
            "MAX": 3,
            "MIN": -3,
            "NAME": "pos3X",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "LABEL": "pos3Y",
            "MAX": 3,
            "MIN": -3,
            "NAME": "pos3Y",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                0.1,
                0.1
            ],
            "LABEL": "Shape Scale XY",
            "MAX": [
                1,
                1
            ],
            "MIN": [
                0,
                0
            ],
            "NAME": "shapeScaleXY",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                3.14,
                3.14
            ],
            "LABEL": "Shape 1 Rotation",
            "MAX": [
                6.28,
                6.28
            ],
            "MIN": [
                0,
                0
            ],
            "NAME": "shape1Rotation",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                3.14,
                3.14
            ],
            "LABEL": "Shape 2 Rotation",
            "MAX": [
                6.28,
                6.28
            ],
            "MIN": [
                0,
                0
            ],
            "NAME": "shape2Rotation",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": [
                3.14,
                3.14
            ],
            "LABEL": "Shape 3 Rotation",
            "MAX": [
                6.28,
                6.28
            ],
            "MIN": [
                0,
                0
            ],
            "NAME": "shape3Rotation",
            "TYPE": "point2D"
        }
    ],
    "ISFVSN": "2"
}
*/


// The MIT License
// Copyright © 2018 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


// A technique used to generate new types of primitives in an exact way,
// without breaking the metric or introducing distortions to the field.


// Related techniques:
//
// Elongation  : https://www.shadertoy.com/view/Ml3fWj
// Rounding    : https://www.shadertoy.com/view/Mt3BDj
// Onion       : https://www.shadertoy.com/view/MlcBDj
// Metric      : https://www.shadertoy.com/view/ltcfDj
// Combination : https://www.shadertoy.com/view/lt3BW2
// Repetition  : https://www.shadertoy.com/view/3syGzz
// Extrusion2D : https://www.shadertoy.com/view/4lyfzw
// Revolution2D: https://www.shadertoy.com/view/4lyfzw
//
// More information here: http://iquilezles.org/www/articles/distfunctions/distfunctions.htm

#define AA 3


//-------------------------------------------------


float opSmoothUnion( float d1, float d2, float k )
{
    float h = max(k-abs(d1-d2),0.0);
    return min(d1, d2) - h*h*0.25/k;
	//float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
	//return mix( d2, d1, h ) - k*h*(1.0-h);
}

float opSmoothSubtraction( float d1, float d2, float k )
{
    float h = max(k-abs(-d1-d2),0.0);
    return max(-d1, d2) + h*h*0.25/k;
	//float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
	//return mix( d2, -d1, h ) + k*h*(1.0-h);
}

float opSmoothIntersection( float d1, float d2, float k )
{
    float h = max(k-abs(d1-d2),0.0);
    return max(d1, d2) + h*h*0.25/k;
	//float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
	//return mix( d2, d1, h ) + k*h*(1.0-h);
}


float opExtrussion( in vec3 p, in float sdf, in float h )
{
    vec2 w = vec2( sdf, abs(p.z) - h );
  	return min(max(w.x,w.y),0.0) + length(max(w,0.0));
}


vec2 opRevolution( in vec3 p, float w )
{
    return vec2( length(p.xz) - w, p.y );
}

vec4 opElongate( in vec3 p, in vec3 h )
{
    //return vec4( p-clamp(p,-h,h), 0.0 ); // faster, but produces zero in the interior elongated box
    
    vec3 q = abs(p)-h;
    return vec4( max(q,0.0), min(max(q.x,max(q.y,q.z)),0.0) );
}

float sdVesica(vec2 p, float r, float d)
{
    p = abs(p);

    float b = sqrt(r*r-d*d); // can delay this sqrt
    return ((p.y-b)*d > p.x*b) 
            ? length(p-vec2(0.0,b))
            : length(p-vec2(-d,0.0))-r;
}

float sdEllipsoid( in vec3 p, in vec3 r )
{
    float k0 = length(p/r);
    float k1 = length(p/(r*r));
    return k0*(k0-1.0)/k1;
}

mat2 Rotate(float a) {
    float s=sin(a); 
    float c=cos(a);
    return mat2(c,-s,s,c);
}

float planeSDF(vec3 p,vec4 n) {
    // n must be normalized
    return dot(p,n.xyz)+n.w;
}


//---------------------------------

float map(in vec3 pos)
{
    float bpm = 360./125.;

    vec3 el1 = pos - vec3(pos1X, pos1Y, 1.0);
    el1.xy *= Rotate(shape1Rotation.x);
    el1.xz *= Rotate(shape1Rotation.y);
    vec4 w = opElongate(el1, vec3(lenX,lenY,lenZ) );
    float d1 = w.w+sdEllipsoid( w.xyz, vec3(shapeScaleXY.x,shapeScaleXY.y,0.1) ) - 0.5;
    d1 += sin(pos.x*5.+TIME*bpm)*0.1 + cos(pos.z*2.+TIME*bpm)*0.3;

    vec3 el2 = pos - vec3(pos2X, pos2Y, 1.0);
    el2.xy *= Rotate(shape2Rotation.x);
    el2.yz *= Rotate(shape2Rotation.y);
    w = opElongate(el2, vec3(lenX,lenY,lenZ) );
    float d2 = w.w+sdEllipsoid( w.xyz, vec3(shapeScaleXY.x,shapeScaleXY.y,0.1)) - 0.25;
    d2 += sin(pos.x*2.+TIME*bpm)*0.1 + cos(pos.z*7.+TIME*bpm)*0.3;

    vec3 el3 = pos - vec3(pos3X, pos3Y, 1.0);
    el3.xy *= Rotate(shape3Rotation.x);
    el3.xz *= Rotate(shape3Rotation.y);
    w = opElongate(el3, vec3(lenX,lenY,lenZ) );
    float d3 = w.w+sdEllipsoid( w.xyz, vec3(shapeScaleXY.x,shapeScaleXY.y,0.1)) - 0.25;
    d3 += sin(pos.x*3.+TIME*bpm)*0.1 + cos(pos.z*5.+TIME*bpm)*0.3;

    float p0 = planeSDF(pos,vec4(0,0,1,0));

    float dt = opSmoothUnion(d1, d2, 0.25);
    dt = opSmoothUnion(dt, d3, 0.25);
    dt = opSmoothUnion(dt, p0, 0.25);

    return dt;
}

// http://iquilezles.org/www/articles/normalsSDF/normalsSDF.htm
vec3 calcNormal( in vec3 pos )
{
    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    return normalize( e.xyy*map( pos + e.xyy*ep ) + 
					  e.yyx*map( pos + e.yyx*ep ) + 
					  e.yxy*map( pos + e.yxy*ep ) + 
					  e.xxx*map( pos + e.xxx*ep ) );
}


void main() {

    vec3 tot = vec3(0.0);
    
    vec2 p = (gl_FragCoord.xy-.5*RENDERSIZE.xy)/RENDERSIZE.y;

    vec3 ro = vec3(0.0,3.0,6.0);
    vec3 rd = normalize(vec3(p-vec2(0.0,1.0),-1.5));
    float t = -7.0;
    for( int i=0; i<64; i++ )
    {
        vec3 p = ro + t*rd;
        float h = map(p);
        if( abs(h)<0.001 || t>10.0 ) break;
        t += h;
    }
    vec3 col = vec3(lightColor);
    if( t<10.0 )
    {
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal(pos);
        // float dif = clamp(dot(nor,vec3(0.57703)),0.0,1.0);
        float dif = clamp(dot(nor,col.rgb),0.0,1.0);
        col = shapeColor.rgb + dif * diffColor.rgb;
    }
    col = sqrt( clamp(col,0.0,1.0) );
    tot += col;

	gl_FragColor = vec4( tot, 1.0 );
}
