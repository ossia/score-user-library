/*{
    "CATEGORIES": [
        "Pyramid",
        "Pattern",
        "Grid"
    ],
    "DESCRIPTION": "",
    "IMPORTED": {
    },
    "INPUTS": [
        {
            "DEFAULT": -10,
            "LABEL": "Scale",
            "MAX": -2,
            "MIN": -20,
            "NAME": "Scale",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                0,
                0
            ],
            "LABEL": "PosXY",
            "MAX": [
                2,
                2
            ],
            "MIN": [
                -2,
                -2
            ],
            "NAME": "PosXY",
            "TYPE": "point2D"
        },
        {
            "DEFAULT": 0.25,
            "LABEL": "Bump",
            "MAX": 0.5,
            "MIN": 0,
            "NAME": "Bump",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.125,
            "LABEL": "tScale",
            "MAX": 1,
            "MIN": 0,
            "NAME": "tScale",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.83,
            "LABEL": "ShadeMult",
            "MAX": 1,
            "MIN": 0,
            "NAME": "ShadeMult",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.17,
            "LABEL": "ShadeAdd",
            "MAX": 1,
            "MIN": 0,
            "NAME": "ShadeAdd",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.17,
            "LABEL": "Vignette",
            "MAX": 1,
            "MIN": 0,
            "NAME": "Vignette",
            "TYPE": "float"
        },
        {
            "DEFAULT": [
                0.5,
                0.2,
                0.9,
                1
            ],
            "LABEL": "SpecColor",
            "NAME": "SpecColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0.1,
                0.3,
                0.9,
                1
            ],
            "LABEL": "FreColor",
            "NAME": "FreColor",
            "TYPE": "color"
        },
        {
            "DEFAULT": [
                0.15,
                0.15,
                0.15,
                1
            ],
            "LABEL": "Color",
            "NAME": "Color",
            "TYPE": "color"
        }
    ],
    "ISFVSN": "2"
}
*/


/*

	Pyramid Pattern
	---------------
	
    An animated pyramid pattern, which is based on old code that I 
    quickly repurposed after looking at Oggbog's "Flipping triangles" 
    example.

	I've departed from the original considerably, but it's essentially 
    the same thing. The pyramid centers have been offset in correlation 
    with a directional gradient that indexes an underlying noise 
    function. I've applied some exaggerated bumped highlighting to give 
    the pattern a sharp abstract scaly appearance.

    The cells are arranged in a square grid with each alternate row 
    offset by half a cell to give a more distributed feel. In fact, I 
    almost coded a hexagonal version, but figured this had more of an 
    angular feel.

	I've commented the code, but there's nothing in here that's
	particularly taxing on the brain. If I had it my way, I'd code 
    simple little geometric patterns all day, since it's kind of 
    therapeutic, but I've got some so-called hard stuff to get back
	to... Well, it's hard for me anyway. :)
     
    Automatically converted from https://www.shadertoy.com/view/wlscWX by Shane.  
    An offset grid of square-based pyramids whose tips have been offset according 
    to an underlying directional noise field. 
    The faux lighting is provided via bump mapping. 
    No raymarching was harmed during the making of this example. :)

	// Here's a much simpler version.
    Offset Pyramid Squares - Shane
	https://www.shadertoy.com/view/tlXcDs

    // Great motion: I sometimes go overboard with bells and 
    // whistles, whereas this is elegantly simple.
	Pyramid torsion - AntoineC
    https://www.shadertoy.com/view/lsVczK

	// Inspired by:
    Flipping triangles - Oggbog
	https://www.shadertoy.com/view/ttsyD2


*/

// Offsetting alternate rows -- I feel it distributes the effect more,
// but if you prefer more order, comment out the following:
#define OFFSET_ROW
#define PI 3.14159
#define TWO_PI 6.2831

// Standard 2D rotation formula.
mat2 rot2(in float a)
{ 
    float c = cos(a), s = sin(a); 
    return mat2(c, -s, s, c); 
}


// IQ's vec2 to float hash.
float hash21(vec2 p) {  
    return fract(sin(dot(p, vec2(27.619, 57.583)))*43758.5453); 
}


vec2 cellID; // Individual Voronoi cell IDs.


// vec2 to vec2 hash.
vec2 hash22B(vec2 p) { 

    // Faster, but doesn't disperse things quite as nicely. However, when framerate
    // is an issue, and it often is, this is a good one to use. Basically, it's a tweaked 
    // amalgamation I put together, based on a couple of other random algorithms I've 
    // seen around... so use it with caution, because I make a tonne of mistakes. :)
    float n = sin(dot(p, vec2(41, 289)));
    return fract(vec2(262144, 32768)*n)*2. - 1.; 
    //return sin( p*6.2831853 + TIME ); 
}

// Based on IQ's gradient noise formula.
float n2D3G( in vec2 p ) {
   
    // Cell ID and local coordinates.
    vec2 i = floor(p); p -= i;
    
    // Four corner samples.
    vec4 v;
    v.x = dot(hash22B(i), p);
    v.y = dot(hash22B(i + vec2(1, 0)), p - vec2(1, 0));
    v.z = dot(hash22B(i + vec2(0, 1)), p - vec2(0, 1));
    v.w = dot(hash22B(i + 1.), p - 1.);

    // Cubic interpolation.
    p = p*p*(3. - 2.*p);
    
    // Bilinear interpolation -- Along X, along Y, then mix.
    return mix(mix(v.x, v.y, p.x), mix(v.z, v.w, p.x), p.y);
    
}

// Two layers of noise.
float fBm(vec2 p) {
    return n2D3G(p)*.66 + n2D3G(p*2.)*.34; 
}


float Map(vec2 p, float tBPM) {
    

    // Put the grid on an angle to interact with the light a little better.
    p *= rot2(-PI/5. * tBPM);

    // Tacky way to construct an offset square grid.
    if(mod(floor(p.y), 2.) < .5) {
        p.x += .5;
    }

    
    // Cell ID and local coordinates.
    vec2 ip = floor(p);
    p -= ip + .5;
    
    // Recording the cell ID.
    cellID = ip;

    // Transcendental angle function... Made up on the spot.
    //float ang = dot(sin(ip/4. - cos(ip.yx/2. + TIME))*TWO_PI, vec2(.5));
    
    // Noise function. I've rotated the point around a bit so that the 
    // objects hang down due to gravity at the zero mark.
    // float ang = -PI * 3. / 5. + (fBm(ip / 8. + TIME / 3.)) * TWO_PI * 2.;
    float ang = -PI * 3. / 5. + (fBm(ip / 8. + TIME / tBPM)) * TWO_PI * 2.;
    // Offset point within the cell. You could increase this to cell edges
    // (.5), but it starts to look a little weird at that point.
    vec2 offs = vec2(cos(ang), sin(ang)) * .35;
     
    // Linear pyramid shading, according to the offset point. Basically, you
    // want a value of zero at the edges and a linear increase to one at the 
    // offset point peak. As you can see, I've just hacked in something quick 
    // that works, but there'd be more elegant ways to achieve the same.
    if(p.x<offs.x)  p.x = 1. - (p.x + .5)/abs(offs.x  + .5);
    else p.x = (p.x - offs.x)/(.5 - offs.x);

    if(p.y<offs.y) p.y = 1. - (p.y + .5)/abs(offs.y + .5);
    else p.y = (p.y - offs.y)/(.5 - offs.y);

    // Return the offset pyramid distance field. Range: [0, 1].
    return 1. - max(p.x, p.y);
}


// Standard function-based bump mapping function, with an edge value 
// included for good measure.
vec3 doBumpMap(in vec2 p, in vec3 n, float bumpfactor, inout float edge, float tBPM){
    
    // Sample difference. Usually, you'd have different ones for the gradient
    // and the edges, but we're finding a happy medium to save cycles.
    vec2 e = vec2(.025, 0);
    
    float f = Map(p, tBPM); // Bump function sample.
    float fx = Map(p - e.xy, tBPM); // Same for the nearby sample in the X-direction.
    float fy = Map(p - e.yx, tBPM); // Same for the nearby sample in the Y-direction.
    float fx2 = Map(p + e.xy, tBPM); // Same for the nearby sample in the X-direction.
    float fy2 = Map(p + e.yx, tBPM); // Same for the nearby sample in the Y-direction.
    
    vec3 grad = (vec3(fx - fx2, fy - fx2, 0))/e.x/2.;   
    
    // Edge value: There's probably all kinds of ways to do it, but this will do.
    edge = length(vec2(fx, fy) + vec2(fx2, fy2) - f*2.);
    // edge = (fx + fy + fx2 + fy2 - f*4.);
    // edge = abs(fx + fx2 - f*2.) + abs(fy + fy2 - f*2.);
    //edge /= e.x;
    edge = smoothstep(0., 1., edge/e.x);
     
    // Applying the bump function gradient to the surface normal.
    grad -= n*dot(n, grad);          
    
    // Return the normalized bumped normal.
    return normalize( n + grad*bumpfactor );
	
}


// A hatch-like algorithm, or a stipple... or some kind of textured pattern.
float doHatch(vec2 p, float res){ 
    
    // The pattern is physically based, so needs to factor in screen resolution.
    p *= res/16.;

    // Random looking diagonal hatch lines.
    float hatch = clamp(sin((p.x - p.y) * PI * 200.) * 2. + .5, 0., 1.); // Diagonal lines.

    // Slight randomization of the diagonal lines, but the trick is to do it with
    // tiny squares instead of pixels.
    float hRnd = hash21(floor(p*6.) + .73);
    if(hRnd > .66) hatch = hRnd;  

    return hatch;
}

int bpm = 135;
float bbpm = 1. / 4.;  // beats per measure
float spm = (bbpm * (float(bpm) / 60.)); // seconds per measure

float tBPM = (spm / tScale);

void main() {

    // Resolution and aspect correct screen coordinates.
    float iRes = min(RENDERSIZE.y, 800.);
    vec2 uv = (gl_FragCoord.xy - RENDERSIZE.xy * .5) / iRes;
    
    // Unit direction vector. Used for some mock lighting.
    vec3 rd = normalize(vec3(uv, .5));
    
    // Scaling and tranlation.
    float gSc = Scale;
    vec2 p = uv * gSc + vec2(sin(TIME / tBPM), cos(TIME / tBPM)) * tScale;
    vec2 oP = p; // Saving a copy for later.

    
    // Take a function sample.
    float m = Map(p, tBPM);
    
    vec2 svID = cellID;
  
    // Face normal for and XY plane sticking out of the screen.
    vec3 n = vec3(0, 0, -1);
    
    // Bump mapping the normal and obtaining an edge value.
    float edge = 0., bumpFactor = Bump;
    n = doBumpMap(p, n, bumpFactor, edge, tBPM);
   
    // Light postion, sitting back from the plane and animated slightly.
	vec3 lp =  vec3(-0. + sin(PosXY.x), .0 + cos(PosXY.y * 1.3), -1) - vec3(uv, 0);
    
    // Liight distance and normalizing.
    float lDist = max(length(lp), .001);
    vec3 ld = lp/lDist;
	
	// Diffuse, specular and Fresnel.
	float diff = max(dot(n, ld), 0.) * Vignette;
    diff = pow(diff, 4.);
    float spec = pow(max(dot(reflect(-ld, n), -rd), 0.), 16.);
	// Fresnel term. Good for giving a surface a bit of a reflective glow.
    float fre = min(pow(max(1. + dot(n, rd), 0.), 4.), 3.);
    
    // Applying the lighting.
    vec3 col = Color.rgb * (diff + .251 + spec * SpecColor.rgb * 9. + fre * FreColor.rgb * 12.);     
    
    float rf = smoothstep(0., 1., Map(reflect(rd, n).xy * 2., tBPM) * fBm(reflect(rd, n).xy * 3.) + 0.3);
    col += col * col * rf * rf * Color.rgb * 15.;
        
     // Using the distance function value for some faux shading.
    float shade = m * ShadeMult + ShadeAdd;
    col *= shade;
    
    // Apply the edging from the bump function. In some situations, this can add an
    // extra touch of dimension. It's so easy to apply that I'm not sure why people 
    // don't use it more. Bump mapped edging works in 3D as well.
    // col *= 1. - edge * .8;
    
    // Apply a cheap but effective hatch function.
    // float hatch = doHatch(oP/gSc, iRes);
    // col *= hatch * .5 + .7;
    
    // Just the distance function.
    //col = vec3(m);
   
  
    // Subtle vignette.
    vec2 uvV = isf_FragNormCoord;
    col = mix(col * vec3(.25, .5, 1) / 8., col, pow(16. * uvV.x * uvV.y * (1. - uvV.x) * (1. - uvV.y), Vignette));
    
	gl_FragColor = vec4(sqrt(max(col, 0.)), 1);
}
