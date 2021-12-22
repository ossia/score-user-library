/*
{
  "IMPORTED" : [

  ],
  "CATEGORIES" : [
    "procedural",
    "aurora",
    "atmosphere",
    "weather",
    "Automatically Converted",
    "Shadertoy"
  ],
  "DESCRIPTION" : "Automatically converted from https:\/\/www.shadertoy.com\/view\/XtGGRt by nimitz.  Trying to get cheap and fully procedural northern lights effect. Looks better in full screen. Could still be improved...",
  "INPUTS" : [
    
    {
			"NAME": "x_pose",
			"TYPE": "float",
			"DEFAULT": 0.0,
			"MIN": -6.0,
			"MAX": 6.0
	},
	{
			"NAME": "y_pose",
			"TYPE": "float",
			"DEFAULT": 0.0,
			"MIN": -1.0,
			"MAX": 1.0
	},
	
	{
			"NAME": "fov",
			"TYPE": "float",
			"DEFAULT": 1.3,
			"MIN": 0.03,
			"MAX": 3.0
	},
	
	{
			"NAME": "autoXmoveSinSpeed",
			"TYPE": "float",
			"DEFAULT": 0.05,
			"MIN": 0.0,
			"MAX": 1.0
	},
	
	{
			"NAME": "autoXmoveSinAmp",
			"TYPE": "float",
			"DEFAULT": 0.2,
			"MIN": 0.0,
			"MAX": 3.0
	},
	
	{
			"NAME": "ro1",
			"TYPE": "float",
			"DEFAULT": 0.0,
			"MIN": -1.0,
			"MAX": 1.0
	},
	
	{
			"NAME": "ro2",
			"TYPE": "float",
			"DEFAULT": 0.0,
			"MIN": -1.0,
			"MAX": 1.0
	},
	{
			"NAME": "ro3",
			"TYPE": "float",
			"DEFAULT": -6.7,
			"MIN": -10.0,
			"MAX": 10.0
	},

    {
			"NAME": "aurora_noise_speed",
			"TYPE": "float",
			"DEFAULT": 0.06,
			"MIN": 0.0,
			"MAX": 5.0
	},
	{
			"NAME": "aurora_noise",
			"TYPE": "float",
			"DEFAULT": 2.5,
			"MIN": 0.9,
			"MAX": 15.0
	},
    {
			"NAME": "aurora_brightnes",
			"TYPE": "float",
			"DEFAULT": 3.0,
			"MIN": -2.0,
			"MAX": 3.8
	},
	{
			"NAME": "starsBrightnes",
			"TYPE": "float",
			"DEFAULT": 1.0,
			"MIN": 0.0,
			"MAX": 1.5
	},
    
	{
			"NAME": "reflection_fade",
			"TYPE": "float",
			"DEFAULT": 2.5,
			"MIN": -2.5,
			"MAX": 3.5
	}
	
  ]
}
*/


//Auroras by nimitz 2017 (twitter: @stormoid)

/*
	
	There are two main hurdles I encountered rendering this effect. 
	First, the nature of the texture that needs to be generated to get a believable effect
	needs to be very specific, with large scale band-like structures, small scale non-smooth variations
	to create the trail-like effect, a method for animating said texture smoothly and finally doing all
	of this cheaply enough to be able to evaluate it several times per fragment/pixel.

	The second obstacle is the need to render a large volume while keeping the computational cost low.
	Since the effect requires the trails to extend way up in the atmosphere to look good, this means
	that the evaluated volume cannot be as constrained as with cloud effects. My solution was to make
	the sample stride increase polynomially, which works very well as long as the trails are lower opcaity than
	the rest of the effect. Which is always the case for auroras.

	After that, there were some issues with getting the correct emission curves and removing banding at lowered
	sample densities, this was fixed by a combination of sample number influenced dithering and slight sample blending.

	N.B. the base setup is from an old shader and ideally the effect would take an arbitrary ray origin and
	direction. But this was not required for this demo and would be trivial to fix.
*/

#define time TIME

mat2 mm2(in float a){float c = cos(a), s = sin(a);return mat2(c,s,-s,c);}
mat2 m2 = mat2(0.95534, 0.29552, -0.29552, 0.95534);
float tri(in float x){return clamp(abs(fract(x)-.5),0.01,0.49);}
vec2 tri2(in vec2 p){return vec2(tri(p.x)+tri(p.y),tri(p.y+tri(p.x)));}

float triNoise2d(in vec2 p, float spd)
{
    float z=4.8-aurora_brightnes;
    float z2=aurora_noise;
	float rz = 0.;
    p *= mm2(p.x*0.06);
    vec2 bp = p;
	for (float i=0.; i<5.; i++ )
	{
        vec2 dg = tri2(bp*1.85)*.75;
        dg *= mm2(time*spd);
        p -= dg/z2;

        bp *= 1.3;
        z2 *= .45;
        z *= 0.42;
		p *= 1.21 + (rz-1.0)*.02;
        
        rz += tri(p.x+tri(p.y))*z;
        p*= -m2;
	}
    return clamp(1./pow(rz*29., 1.3),0.,.55);
}

float hash21(in vec2 n){ return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453); }
vec4 aurora(vec3 ro, vec3 rd)
{
    vec4 col = vec4(0);
    vec4 avgCol = vec4(0);
    
    for(float i=0.;i<50.;i++)
    {
        float of = 0.006*hash21(gl_FragCoord.xy)*smoothstep(0.,15., i);
        float pt = ((.8+pow(i,1.4)*.002)-ro.y)/(rd.y*2.+0.4);
        pt -= of;
    	vec3 bpos = ro + pt*rd;
        vec2 p = bpos.zx;
        float rzt = triNoise2d(p, aurora_noise_speed);
        vec4 col2 = vec4(0,0,0, rzt);
        col2.rgb = (sin(1.-vec3(2.15,-.5, 1.2)+i*0.043)*0.5+0.5)*rzt;
        avgCol =  mix(avgCol, col2, .5);
        col += avgCol*exp2(-i*0.065 - 2.5)*smoothstep(0.,5., i);
        
    }
    
    col *= (clamp(rd.y*15.+.4,0.,1.));
    
    
    //return clamp(pow(col,vec4(1.3))*1.5,0.,1.);
    //return clamp(pow(col,vec4(1.7))*2.,0.,1.);
    //return clamp(pow(col,vec4(1.5))*2.5,0.,1.);
    //return clamp(pow(col,vec4(1.8))*1.5,0.,1.);
    
    //return smoothstep(0.,1.1,pow(col,vec4(1.))*1.5);
    return col*1.8;
    //return pow(col,vec4(1.))*2.
}


//-------------------Background and Stars--------------------

//From Dave_Hoskins (https://www.shadertoy.com/view/4djSRW)
vec3 hash33(vec3 p)
{
    p = fract(p * vec3(443.8975,397.2973, 491.1871));
    p += dot(p.zxy, p.yxz+19.27);
    return fract(vec3(p.x * p.y, p.z*p.x, p.y*p.z));
}

vec3 stars(in vec3 p)
{
    vec3 c = vec3(0.);
    float res = RENDERSIZE.x*1.;
    
	for (float i=0.;i<4.;i++)
    {
        vec3 q = fract(p*(.15*res))-0.5;
        vec3 id = floor(p*(.15*res));
        vec2 rn = hash33(id).xy;
        float c2 = 1.-smoothstep(0.,.6,length(q));
        c2 *= step(rn.x,.0005+i*i*0.001);
        c += c2*(mix(vec3(1.0,0.49,0.1),vec3(0.75,0.9,1.),rn.y)*0.1+0.9);
        p *= 1.3;
    }
    return c*c*.8;
}

vec3 bg(in vec3 rd)
{
    float sd = dot(normalize(vec3(-0.5, -0.6, 0.9)), rd)*0.5+0.5;
    sd = pow(sd, 5.);
    vec3 col = mix(vec3(0.05,0.1,0.2), vec3(0.1,0.05,0.2), sd);
    return col*.63;
}
//-----------------------------------------------------------


void main() {



	vec2 q = gl_FragCoord.xy / RENDERSIZE.xy;
    vec2 p = q - 0.5;
	p.x*=RENDERSIZE.x/RENDERSIZE.y;
    
    vec3 ro = vec3(ro1,ro2,ro3);
    vec3 rd = normalize(vec3(p,fov));
    //vec2 mo = iMouse.xy / RENDERSIZE.xy-.5;
    //mo = (mo==vec2(-.5))?mo=vec2(-0.1,0.1):mo;
	//mo.x *= RENDERSIZE.x/RENDERSIZE.y;
    rd.yz *= mm2(y_pose);
    rd.xz *= mm2(x_pose + sin(time*autoXmoveSinSpeed)*autoXmoveSinAmp);
    
    vec3 col = vec3(0.);
    vec3 brd = rd;
    float fade = smoothstep(0.,0.01,abs(brd.y))*0.1+0.9;
    
    col = bg(rd)*fade;
    
    if (rd.y > 0.){
        vec4 aur = smoothstep(0.,1.5,aurora(ro,rd))*fade;
        col += (stars(rd)*starsBrightnes);
        col = col*(1.-aur.a) + aur.rgb;
    }
    else //Reflections
    {
        rd.y = abs(rd.y);
        col = bg(rd)*fade*0.6;
        vec4 aur = smoothstep(0.0,5.0-reflection_fade,aurora(ro,rd));
        col += (stars(rd)*starsBrightnes)*0.3;
        col = col*(1.-aur.a) + aur.rgb;
        vec3 pos = ro + ((0.5-ro.y)/rd.y)*rd;
        float nz2 = triNoise2d(pos.xz*vec2(.5,.7), 0.);
        col += mix(vec3(0.2,0.25,0.5)*0.08,vec3(0.3,0.3,0.5)*0.7, nz2*0.4);
    }
    
	gl_FragColor = vec4(col, 1.);
}
