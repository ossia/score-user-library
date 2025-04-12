/*
{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Analytic motion blur. A sphere is checked for intersection while moving linearly. The resulting equation is a quadratic in two parameters (distance and time), and returns the time coverage of the swept disk over the aperture of the camera for a given ray",
    "IMPORTED": {
    },
    "INPUTS": [
    ]
}

*/


// Analytic motion blur, for spheres
//
// (Linearly) Moving Spheres vs ray intersection test. The resulting equation is a double
// quadratic in two parameters, distance (as usual in regular raytracing) and time. It's sort
// of space-time raytracing if you wish.
// 
// The quadratic(s) are solved to get the time interval of the intersection, and the distances.
// Shading is performed only once at the middle of the time interval.
//
// This method allows for (virtually) inexpensive motion blur, without time supersampling.
//

// intersect a MOVING sphere
vec2 iSphere( in vec3 ro, in vec3 rd, in vec4 sp, in vec3 ve, out vec3 nor )
{
    float t = -1.0;
	float s = 0.0;
	nor = vec3(0.0);
	
	vec3  rc = ro - sp.xyz;
	float A = dot(rc,rd);
	float B = dot(rc,rc) - sp.w*sp.w;
	float C = dot(ve,ve);
	float D = dot(rc,ve);
	float E = dot(rd,ve);
	float aab = A*A - B;
	float eec = E*E - C;
	float aed = A*E - D;
	float k = aed*aed - eec*aab;
		
	if( k>0.0 )
	{
		k = sqrt(k);
		float ta = max( 0.0, (aed+k)/eec );
		float tb = min( 1.0, (aed-k)/eec );
		if( ta < tb )
		{
            ta = 0.5*(ta+tb);			
            t = -(A-E*ta) - sqrt( (A-E*ta)*(A-E*ta) - (B+C*ta*ta-2.0*D*ta) );
            s = 2.0*(tb - ta);
            nor = normalize( (ro+rd*t) - (sp.xyz+ta*ve ) );
		}
	}

	return vec2(t,s);
}

// intersect a STATIC sphere
float iSphere( in vec3 ro, in vec3 rd, in vec4 sp, out vec3 nor )
{
    float t = -1.0;
	nor = vec3(0.0);
	
	vec3  rc = ro - sp.xyz;
	float b =  dot(rc,rd);
	float c =  dot(rc,rc) - sp.w*sp.w;
	float k = b*b - c;
	if( k>0.0 )
	{
		t = -b - sqrt(k);
		nor = normalize( (ro+rd*t) - sp.xyz );
	}

	return t;
}

vec3 getPosition( float time ) { return vec3(     2.5*sin(8.0*time), 0.0,      1.0*cos(8.0*time) ); }
vec3 getVelocity( float time ) { return vec3( 8.0*2.5*cos(8.0*time), 0.0, -8.0*1.0*sin(8.0*time) ); }

void main() {

	vec2 q = isf_FragNormCoord;
	vec2 p = -1.0 + 2.0*q;
	p.x *= RENDERSIZE.x/RENDERSIZE.y;	
	// camera
	vec3  ro = vec3(0.0,0.0,4.0);
    vec3  rd = normalize( vec3(p.xy,-2.0) );
	
    // sphere	
	
	// render
	vec3  col = vec3(0.0);

    //---------------------------------------------------	
    // render with analytical motion blur
    //---------------------------------------------------	
	vec3  ce = getPosition( 0. );
	vec3  ve = getVelocity( 0. );
    	
	col = vec3(0.25) + 0.3*rd.y;
	vec3 nor = vec3(0.0);
	vec3 tot = vec3(0.25) + 0.3*rd.y;
    vec2 res = iSphere( ro, rd, vec4(ce,1.0), ve/24.0, nor );
	float t = res.x;
	if( t>0.0 )
	{
		float dif = clamp( dot(nor,vec3(0.5703)), 0.0, 1.0 );
		float amb = 0.5 + 0.5*nor.y;
		vec3  lcol = dif*vec3(1.0,0.9,0.3) + amb*vec3(0.1,0.2,0.3);
		col = mix( tot, lcol, res.y );
	}
	
	col = pow( clamp(col,0.0,1.0), vec3(0.45) );
	gl_FragColor = vec4( col, 1.0 );
}
