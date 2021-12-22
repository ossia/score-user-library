/*{
    "CATEGORIES": [
        "Transparent",
        "Cube",
        "Field"
    ],
    "DESCRIPTION": "Automatically converted from https://www.shadertoy.com/view/ll2SRy by Shane.  Some simple code to produce a relatively cheap, transparent cube field.",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": [
                0,
                0.6666666666666666,
                1,
                1
            ],
            "LABEL": "Color",
            "NAME": "Color",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0.4549019607843137,
                0,
                0.6823529411764706,
                1
            ],
            "LABEL": "Mix Color",
            "NAME": "MixColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": 0.375,
            "LABEL": "Skew",
            "MAX": 1,
            "MIN": 0,
            "NAME": "Skew",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.2,
            "LABEL": "Transparency",
            "MAX": 0.35,
            "MIN": 0.15,
            "NAME": "Transparency",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.2,
            "LABEL": "ColorSaturation",
            "MAX": 0.8,
            "MIN": 0,
            "NAME": "ColorSaturation",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.5,
            "LABEL": "Scale",
            "MAX": 1.4,
            "MIN": 0.4,
            "NAME": "Scale",
            "TYPE": "float"
        },
        {
            "DEFAULT": 1,
            "LABEL": "Perturb",
            "MAX": 100,
            "MIN": 1,
            "NAME": "Perturb",
            "TYPE": "float"
        },
        {
            "DEFAULT": 10,
            "LABEL": "Perturb X",
            "MAX": 100,
            "MIN": 1,
            "NAME": "PerturbX",
            "TYPE": "float"
        },
        {
            "DEFAULT": 10,
            "LABEL": "Perturb Y",
            "MAX": 100,
            "MIN": 1,
            "NAME": "PerturbY",
            "TYPE": "float"
        },
        {
            "DEFAULT": 10,
            "LABEL": "Perturb Z",
            "MAX": 100,
            "MIN": 1,
            "NAME": "PerturbZ",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.001,
            "LABEL": "Time",
            "MAX": 1,
            "MIN": 0,
            "NAME": "Time",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/


/*

    Transparent Cube Field
    ----------------------
	
	Obviously, this isn't what I'd consider genuine transparency, because there's no
	ray bending, and so forth. However, it attempts to give that feel whilst maintaining 
	framerate. I've tried to keep things simple and keep the code to a minimum. It needs 
	some God rays, but that'd just add to the complexity.

	The inspiration to do this came from a discussion with Fabrice Neyret, after viewing
	his various cube examples. He's a pretty clever guy, so he'll probably know how to do 
	this ten times faster with ten times more efficiency. :)

	It doesn't look much like it, but Duke's port of Las's "Cloudy Spikeball" also provided 
	inspiration.

	By the way, I deliberately made it blurry, and added more jitter than necessary in the
	pursuit of demo art. :) However, you can tweak the figures and dull down the jitter	to 
	produce a reasonably clean looking, transparent scene... of vacuum filled objects. :)

	// Related shaders:
    Transparent Cube Field - by Shane
    https://www.shadertoy.com/view/ll2SRy

	Crowded Cubes 2 - FabriceNeyret2
	https://www.shadertoy.com/view/ltBSRy

	Cloudy Spikeball - Duke
    https://www.shadertoy.com/view/MljXDw
    // Port from a demo by Las - Worth watching.
    // http://www.pouet.net/prod.php?which=56866
    // http://www.pouet.net/topic.php?which=7920&page=29&x=14&y=9

    // Here's a more interesting, cleaner version.
    Transparent Lattice - Shane
    https://www.shadertoy.com/view/Xd3SDs
	
*/


// Cheap vec3 to vec3 hash. Works well enough, but there are other ways.
vec3 hash33(vec3 p){ 
    float n = sin(dot(p, vec3(7, 157, 113)));    
    return fract(vec3(2097152, 762144, 302768)*n); 
}

int bpm = 60;
float bbpm = 1. / 4.;  // beats per measure
float spm = (bbpm * (float(bpm) / 60.)); // seconds per measure

float map(vec3 p){
   
    // scale
    p *= Scale;

    // surface change
    float time = Time;
    float fTime = sin(TIME * time * Perturb);
    float pX = PerturbX;
    float pY = PerturbY;
    float pZ = PerturbZ;
    float perturb = sin(fTime * p.x * pX) * sin(fTime * p.y * pY) * sin(fTime * p.z * pZ);

    // grid
	p += hash33(floor(p + 20.)) * .2;

    // sphere
    float sphere = length(fract(p) -.5) - 0.25 + perturb * 0.05;
	return sphere;
	
}


void main() {

    
    // Screen coordinates.
	vec2 uv = (gl_FragCoord.xy - RENDERSIZE.xy*.5 )/RENDERSIZE.y;
	
    // Unit direction ray. The last term is one of many ways to fish-lens the camera.
    // For a regular view, set "rd.z" to something like "0.5."
    vec3 rd = normalize(vec3(uv, (1.-dot(uv, uv)*.5)*.5)); // Fish lens, for that 1337, but tryhardish, demo look. :)
    
    // There are a few ways to hide artifacts and inconsistencies. Making things go fast is one of them. :)
    // Ray origin, scene color, and surface postion vector.
    vec3 ro = vec3(0., 0., TIME * 3.);
    // vec3 ro = vec3(0., 0., 3.);
    vec3 col = Color.rgb;
    vec3 sp;
	
    // Swivel the unit ray to look around the scene.
	float cs = cos( TIME * Skew ), si = sin( TIME * Skew );    
    rd.xz = mat2(cs, si, -si, cs)*rd.xz;
    rd.xy = mat2(cs, si, -si, cs)*rd.xy;
    
    // Unit ray jitter is another way to hide artifacts. It can also trick the viewer into believing
    // something hard core, like global illumination, is happening. :)
    // rd *= 0.985 + hash33(rd)*0.03;
    
    
	// Ray distance, bail out layer number, surface distance and normalized accumulated distance.
	float t=0., layers=0., d, aD;
    
    // Surface distance threshold. Smaller numbers give a sharper object. I deliberately
    // wanted some blur, so bumped it up slightly.
    float thD = .009 + smoothstep(-0.2, 0.2, sin(TIME*0.75 - 3.14159*0.4))*0.025;
	
    // Only a few iterations seemed to be enough. Obviously, more looks better, but is slower.
	for(int i=0; i < 256; i++)	{
        
        // Break conditions. Anything that can help you bail early usually increases frame rate.
        if(layers > 30. || col.x > 0.8 || t > 20.) break;
        
        // Current ray postion. Slightly redundant here, but sometimes you may wish to reuse
        // it during the accumulation stage.
        sp = ro + rd * t;
		
        d = map(sp); // Distance to nearest point in the cube field.
        
        // If we get within a certain distance of the surface, accumulate some surface values.
        // Values further away have less influence on the total.
        //
        // aD - Accumulated distance. I interpolated aD on a whim (see below), because it seemed 
        // to look nicer.
        //
        // 1/.(1. + t*t*.25) - Basic distance attenuation. Feel free to substitute your own.
        
         // Normalized distance from the surface threshold value to our current isosurface value.
        aD = (thD - abs(d) * 15. / 16.) / thD;
        
        // If we're within the surface threshold, accumulate some color.
        // Two "if" statements in a shader loop makes me nervous. I don't suspect there'll be any
        // problems, but if there are, let us know.
        if(aD > 0.) { 
            // Smoothly interpolate the accumulated surface distance value, then apply some
            // basic falloff (fog, if you prefer) using the camera to surface distance, "t."
            // col += aD * aD *(3. - 2. * aD)/(1. + t * t *.25) * .2; 
            col += aD * aD *(3. - 2. * aD)/(1. + t * t * 0.025) * Transparency; 
            layers++; 
        }
		
        // Kind of weird the way this works. I think not allowing the ray to hone in properly is
        // the very thing that gives an even spread of values. The figures are based on a bit of 
        // knowledge versus trial and error. If you have a faster computer, feel free to tweak
        // them a bit.
        t += max(abs(d) * .7, thD * 1.5); 
        
			    
	}
    
    // I'm virtually positive "col" doesn't drop below zero, but just to be safe...
    col = clamp(col, 0., 1.);
    // col = min(col, 1.);
    
    // Mixing the greytone color and some firey orange with a sinusoidal pattern that
    // was completely made up on the spot.
    vec3 mixColorA = vec3(min(MixColor.r * 1., 0.8), pow(MixColor.g * 1., 0.8), pow(MixColor.b * 1., 0.8));
    // float mixRatioA = dot(sin(rd.yzx * 8. + sin(rd.zxy * 8.)), vec3(.1666)) + ColorSaturation;
    col = mix(col, 4. * mixColorA, clamp(ColorSaturation, 0., 0.5 * ColorSaturation));
    
    
	// Doing the same again, but this time mixing in some green. I might have gone overboard
    // applying this step. Commenting it out probably looks more sophisticated.
    vec3 mixColorB = vec3(MixColor.r * MixColor.r * .85, MixColor.g, MixColor.b * MixColor.b * .3);
    // float mixRatioB = dot(sin(rd.zyx * 8. + sin(rd.zxy * 8.)), vec3(.32332)) + ColorSaturation;
    col = mix(col, 2. * mixColorB, clamp(ColorSaturation, 0., ColorSaturation));

    col = pow(col, vec3(1.9));	// gamma correction

	gl_FragColor = vec4(clamp(col, 0., 1.), 1);
    
     
}
