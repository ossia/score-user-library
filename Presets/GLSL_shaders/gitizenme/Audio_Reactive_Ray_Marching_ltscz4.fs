/*
{
    "CATEGORIES": [
        "Automatically Converted",
        "Shadertoy"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/ltscz4 by wizgrav.  clubber mod of https://www.shadertoy.com/view/4t2SWW",
    "IMPORTED": {
        "iChannel0": {
            "NAME": "iChannel0",
            "PATH": [
                "793a105653fbdadabdc1325ca08675e1ce48ae5f12e37973829c87bea4be3232.png",
                "793a105653fbdadabdc1325ca08675e1ce48ae5f12e37973829c87bea4be3232_1.png",
                "793a105653fbdadabdc1325ca08675e1ce48ae5f12e37973829c87bea4be3232_2.png",
                "793a105653fbdadabdc1325ca08675e1ce48ae5f12e37973829c87bea4be3232_3.png",
                "793a105653fbdadabdc1325ca08675e1ce48ae5f12e37973829c87bea4be3232_4.png",
                "793a105653fbdadabdc1325ca08675e1ce48ae5f12e37973829c87bea4be3232_5.png"
            ],
            "TYPE": "cube"
        },
        "iChannel1": {
            "NAME": "iChannel1",
            "PATH": "92d7758c402f0927011ca8d0a7e40251439fba3a1dac26f5b8b62026323501aa.jpg"
        }
    },
    "INPUTS": [
        {
            "NAME": "iMouse",
            "TYPE": "point2D"
        }
    ]
}

*/


// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

float dstef = 0.0;
    
// based on my 2d shader https://www.shadertoy.com/view/llSSWD
vec3 effect(vec2 g) 
{
    float t = TIME * 1.5;
    g /= 200.;
    g.x -= t * .015;
	g.y += sin(g.x * 46.5 + t) * .12;
	vec3 c = textureLod(iChannel1, g, 4.*(sin(t)*.5+.5)).rgb;
	c = smoothstep(c+.5, c, vec3(.71));
    return c;
}

///////FRAMEWORK////////////////////////////////////
#define mPi 3.14159
#define m2Pi 6.28318
vec2 uvMap(vec3 p)
{
	p = normalize(p);
	vec2 tex2DToSphere3D;
	tex2DToSphere3D.x = 0.5 + atan(p.z, p.x) / m2Pi;
	tex2DToSphere3D.y = 0.5 - asin(p.y) / mPi;
	return tex2DToSphere3D;
}

vec4 displacement(vec3 p)
{
	vec3 col = effect(p.xz);
    
	col = clamp(col, vec3(0), vec3(1.));
    
	float dist = dot(col,vec3(0.3)); 
    
	return vec4(dist,col);
}

////////BASE OBJECTS///////////////////////
float obox( vec3 p, vec3 b ){ return length(max(abs(p)-b,0.0));}
float osphere( vec3 p, float r ){ return length(p)-r;}
////////MAP////////////////////////////////
vec4 map(vec3 p)
{
	float scale = 1.; // displace scale
	float dist = 0.;
    
	float x = 6.;
	float z = 6.;
    
	vec4 disp = displacement(p);
        
	float y = 1. - smoothstep(0., 1., disp.x) * scale;
    
	dist = osphere(p, +5.-y);
    
	return vec4(dist, disp.yzw);
}

vec3 calcNormal( in vec3 pos, float prec )
{
	vec3 eps = vec3( prec, 0., 0. );
	vec3 nor = vec3(
        map(pos+eps.xyy).x - map(pos-eps.xyy).x,
        map(pos+eps.yxy).x - map(pos-eps.yxy).x,
        map(pos+eps.yyx).x - map(pos-eps.yyx).x );
	return normalize(nor);
}

float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
	float sca = 1.0;
	for( int i=0; i<5; i++ )
    
	{
		float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
	return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

////////MAIN///////////////////////////////
void main() {



    float cam_a = 3.3; // angle z
    
    float cam_e = 6.; // elevation
    float cam_d = 2.; // distance to origin axis
   	
    vec3 camUp=vec3(0,1,0);//Change camere up vector here
  	vec3 camView=vec3(0,0,0); //Change camere view here
  	float li = 0.6; // light intensity
    float prec = 0.00001; // ray marching precision
    float maxd = 50.; // ray marching distance max
    float refl_i = .6; // reflexion intensity
    float refr_a = 1.2; // refraction angle
    float refr_i = .8; // refraction intensity
    float bii = 0.35; // bright init intensity
    float marchPrecision = 0.5; // ray marching tolerance precision
    
    /////////////////////////////////////////////////////////
    if ( iMouse.z>0.) cam_e = iMouse.x/RENDERSIZE.x * 10.; // mouse x axis 
    if ( iMouse.z>0.) cam_d = iMouse.y/RENDERSIZE.y * 50.; // mouse y axis 
    /////////////////////////////////////////////////////////
    
	vec2 uv = isf_FragNormCoord * 2. -1.;
    uv.x*=RENDERSIZE.x/RENDERSIZE.y;
    
    vec3 col = vec3(0.);
    
    vec3 ro = vec3(-sin(cam_a)*cam_d, cam_e+1., cos(cam_a)*cam_d); //
  	vec3 rov = normalize(camView-ro);
    vec3 u = normalize(cross(camUp,rov));
  	vec3 v = cross(rov,u);
  	vec3 rd = normalize(rov + uv.x*u + uv.y*v);
    
    float b = bii;
    
    float d = 0.;
    vec3 p = ro+rd*d;
    float s = prec;
    
    vec3 ray, cubeRay;
    
    for(int i=0;i<250;i++)
	{      
		if (s<prec||s>maxd) break;
		s = map(p).x*marchPrecision;
		d += s;
		p = ro+rd*d;
	}
	if (d<maxd)
	{
		vec2 e = vec2(-1., 1.)*0.005; 
		vec3 n = calcNormal(p, 0.1);
		b=li;
		ray = reflect(rd, n);
		cubeRay = textureCube(iChannel0,ray).rgb  * refl_i ;
		ray = refract(ray, n, refr_a);
		cubeRay += textureCube(iChannel0,ray).rgb * refr_i;
		col = cubeRay+pow(b,15.); 
            
            // lighting        
		float occ = calcAO( p, n );
		vec3  lig = normalize( vec3(-0.6, 0.7, -0.5) );
		float amb = clamp( 0.5+0.5*n.y, 0.0, 1.0 );
		float dif = clamp( dot( n, lig ), 0.0, 1.0 );
		float bac = clamp( dot( n, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-p.y,0.0,1.0);
		float dom = smoothstep( -0.1, 0.1, cubeRay.y );
		float fre = pow( clamp(1.0+dot(n,rd),0.0,1.0), 2.0 );
		float spe = pow(clamp( dot( cubeRay, lig ), 0.0, 1.0 ),16.0);
		vec3 brdf = vec3(0.0);
		brdf += 1.20*dif*vec3(1.00,0.90,0.60);
		brdf += 1.20*spe*vec3(1.00,0.90,0.60)*dif;
		brdf += 0.30*amb*vec3(0.50,0.70,1.00)*occ;
		brdf += 0.40*dom*vec3(0.50,0.70,1.00)*occ;
		brdf += 0.30*bac*vec3(0.25,0.25,0.25)*occ;
		brdf += 0.40*fre*vec3(1.00,1.00,1.00)*occ;
		brdf += 0.02;
		col = col*brdf;
		col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.0005*d*d ) );
		col = mix(col, map(p).yzw, 0.5);
	}
	else
	{
		col = textureCube(iChannel0,rd).rgb;
	}
    //col *= dstef;
    
	gl_FragColor.rgb = col;
}
