/*{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/MlsSzn by iq.  Fale occlusion (approximation) for ellpsoids",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": 0,
            "LABEL": "scale",
            "MAX": 1,
            "MIN": -1,
            "NAME": "scale",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                0.1,
                0.5,
                0.8,
                1
            ],
            "LABEL": "color",
            "NAME": "color",
            "TYPE": "color"
        },
        {
            "DEFAULT": 0.5,
            "LABEL": "Light X",
            "MAX": 6.28,
            "MIN": -6.28,
            "NAME": "lightX",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.3,
            "LABEL": "Light Y",
            "MAX": 6.28,
            "MIN": -6.28,
            "NAME": "lightY",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.4,
            "LABEL": "Light Z",
            "MAX": 6.28,
            "MIN": -6.28,
            "NAME": "lightZ",
            "TYPE": "float"
        },
        {
            "DEFAULT": -10,
            "LABEL": "Zoom",
            "MAX": -2,
            "MIN": -10,
            "NAME": "zoom",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1.5,
            "LABEL": "Len X",
            "MAX": 6.28,
            "MIN": -6.28,
            "NAME": "lenX",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.6,
            "LABEL": "Len Y",
            "MAX": 6.28,
            "MIN": -6.28,
            "NAME": "lenY",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1.5,
            "LABEL": "Len Z",
            "MAX": 6.28,
            "MIN": 0,
            "NAME": "lenZ",
            "TYPE": "float"
        }
        
    ],
    "ISFVSN": "2"
}
*/


// The MIT License
// Copyright © 2015 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


// Compute fake occlusion for ellipsode objects.

// Other shaders with analytical occlusion or approximations:
// 
// Box:                        https://www.shadertoy.com/view/4djXDy
// Box with horizon clipping:  https://www.shadertoy.com/view/4sSXDV
// Triangle:                   https://www.shadertoy.com/view/XdjSDy
// Sphere:                     https://www.shadertoy.com/view/4djSDy
// Ellipsoid (approximation):  https://www.shadertoy.com/view/MlsSzn
// Capsule (approximation):    https://www.shadertoy.com/view/llGyzG


//-------------------------------------------------------------------------------------------
// ellipsoid related functions
//-------------------------------------------------------------------------------------------

struct Ellipsoid
{
    vec3 cen;
    vec3 rad;
};

float eliShadow( in vec3 ro, in vec3 rd, in Ellipsoid sph, in float k )
{
    vec3 oc = ro - sph.cen;
    
    vec3 ocn = oc / sph.rad;
    vec3 rdn = rd / sph.rad;
    
    float a = dot( rdn, rdn );
	float b = dot( ocn, rdn );
	float c = dot( ocn, ocn );

    if( b>0.0 || (b*b-a*(c-1.0))<0.0 ) return 1.0;
    
    return 0.0;
}

float eliSoftShadow( in vec3 ro, in vec3 rd, in Ellipsoid sph, in float k )
{
    vec3 oc = ro - sph.cen;
    
    vec3 ocn = oc / sph.rad;
    vec3 rdn = rd / sph.rad;
    
    float a = dot( rdn, rdn );
	float b = dot( ocn, rdn );
	float c = dot( ocn, ocn );
	float h = b*b - a*(c-1.0);


    float t = (-b - sqrt( max(h,0.0) ))/a;

    return (h>0.0) ? step(t,0.0) : smoothstep(0.0, 1.0, -k*h/max(t,0.0) );
}    
            
vec3 eliNormal( in vec3 pos, in Ellipsoid sph )
{
    return normalize( (pos-sph.cen)/sph.rad );
}

float eliOcclusion( in vec3 pos, in vec3 nor, in Ellipsoid sph )
{
    vec3  r = (sph.cen - pos)/sph.rad;
    float l = length(r);
    return dot(nor,r)/(l*l*l);
}


float eliIntersect( in vec3 ro, in vec3 rd, in Ellipsoid sph )
{
    vec3 oc = ro - sph.cen;
    
    vec3 ocn = oc / sph.rad;
    vec3 rdn = rd / sph.rad;
    
    float a = dot( rdn, rdn );
	float b = dot( ocn, rdn );
	float c = dot( ocn, ocn );
	float h = b*b - a*(c-1.0);
	if( h<0.0 ) return -1.0;
	return (-b - sqrt( h ))/a;
}

vec4 opElongate( in vec3 p, in vec3 h )
{
    //return vec4( p-clamp(p,-h,h), 0.0 ); // faster, but produces zero in the interior elongated box
    
    vec3 q = abs(p)-h;
    return vec4( max(q,0.0), min(max(q.x,max(q.y,q.z)),0.0) );
}

//=====================================================

vec2 hash2( float n ) { return fract(sin(vec2(n,n+1.0))*vec2(43758.5453123,22578.1459123)); }

float iPlane( in vec3 ro, in vec3 rd )
{
    return (-6.0 - ro.y)/rd.y;
}

void main() {

	vec2 p = (2.0*gl_FragCoord.xy-RENDERSIZE.xy) / RENDERSIZE.y;
    
	vec3 ro = vec3(0.0, 0.0, -zoom );
	vec3 rd = normalize( vec3(p,-2.0) );
	
    // sphere animation
    Ellipsoid sph = Ellipsoid( 
        vec3(0.0,0.0,3.0),
        vec3(lenX, lenY, lenZ) + vec3(1.0,0.4,1.0) * scale
        );

    vec4 w = opElongate( q, vec3(0.2,0.0,0.3) );

    vec3 lig = normalize( vec3(lightX,lightY,lightZ) );
    vec3 col = vec3(0.0);
    float tmin = 1e10;
    vec3 nor;
    float occ = 1.0;
    
    float t1 = iPlane( ro, rd );
    if( t1>0.0 )
    {
        tmin = t1;
        vec3 pos = ro + t1*rd;
        nor = vec3(0.0,1.0,0.0);
        occ = 1.0 - eliOcclusion( pos, nor, sph );
    }
    float t2 = eliIntersect( ro, rd, sph );
    if( t2>0.0 && t2<tmin )
    {
        tmin = t2;
        vec3 pos = ro + t2*rd;
        nor = eliNormal( pos, sph );
        occ = 0.5 + 0.5*nor.y;
	}
    
    if( tmin<1000.0 )
    {
        vec3 pos = ro + tmin*rd;
        
		col = vec3(color);
        col *= clamp( dot(nor,lig), 0.05, 1.0 );
        // col *= eliSoftShadow( pos + nor*0.01, lig, sph, 2.0 );
        col += 0.05*occ;
//        col = vec3(occ);
	    col *= exp( -0.05*tmin );
    }
    col = sqrt(col);
    gl_FragColor = vec4( col, 1.0 );
}
