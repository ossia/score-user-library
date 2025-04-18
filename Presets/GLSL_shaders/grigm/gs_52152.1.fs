/*
{
  "CATEGORIES" : [
    "Automatically Converted",
    "GLSLSandbox"
  ],
  "INPUTS" : [

  ],
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#52152.1"
}
*/


#ifdef GL_ES
precision mediump float;
#endif

// glslsandbox uniforms

// shadertoy globals
float iTime = 0.0;
vec3  iResolution = vec3(0.0);

void mainImage (out vec4 fragColor, in vec2 fragCoord);
void main(void) {
    iTime = TIME;
    iResolution = vec3(RENDERSIZE, 0.0);

	vec2 coord = gl_FragCoord.xy;
	coord.y += RENDERSIZE.y/6.;
	vec2 mc = mod(coord, 3.);
	coord -= mc;
    mainImage(gl_FragColor, coord);
	gl_FragColor.rgb += 2.*vec3(.1,.07,.03)*pow(length(gl_FragColor*vec4(1,1,0,0)), 4.);
	gl_FragColor.rgb += 0.2*vec3(.06,.05,.04)*pow(length(gl_FragColor*vec4(1,1,1,0)), 3.);
	gl_FragColor.rgb += vec3(.003,.0,.0)*pow(length(gl_FragColor*vec4(1,0,0,0)), 12.);
	
	gl_FragColor.rgb *= vec3(.75);
	if(max(mc.x, mc.y) <= 1.) gl_FragColor.rgb *= vec3(.92);
	if(min(mc.x, mc.y) <= 1.) gl_FragColor.rgb *= vec3(.96);
}



/*
 * Original shader from: https://www.shadertoy.com/view/4tdSWr
 */

const float cloudscale = 1.1;
const float speed = 0.0125;
const float clouddark = 0.5;
const float cloudlight = 0.3;
const float cloudcover = 0.2;
const float cloudalpha = 8.0;
const float skytint = 0.5;
const vec3 skycolour1 = vec3(0.4,0.41,.7)*0.333+vec3(0.2, 0.4, 0.6);
const vec3 skycolour2 = vec3(0.4, 0.7, 1.0);

const mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );

vec2 hash( vec2 p ) {
	p = vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)));
	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec2 p ) {
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;
	vec2 i = floor(p + (p.x+p.y)*K1);	
    vec2 a = p - i + (i.x+i.y)*K2;
    vec2 o = (a.x>a.y) ? vec2(1.0,0.0) : vec2(0.0,1.0); //vec2 of = 0.5 + 0.5*vec2(sign(a.x-a.y), sign(a.y-a.x));
    vec2 b = a - o + K2;
	vec2 c = a - 1.0 + 2.0*K2;
    vec3 h = max(0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
	vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
    return dot(n, vec3(70.0));	
}

float fbm(vec2 n) {
	float total = 0.0, amplitude = 0.1;
	for (int i = 0; i < 7; i++) {
		total += noise(n) * amplitude;
		n = m * n;
		amplitude *= 0.4;
	}
	return total;
}

// -----------------------------------------------

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{ fragColor = vec4(0., 0., 0., 1.);
    //fragCoord.x *= 1.5-0.5*pow(fragCoord.y/RENDERSIZE.y-.25, 2.);
	float flip = 1.;
	if(fragCoord.y <= RENDERSIZE.y/2.){
		flip = .5+.92*fragCoord.y/RENDERSIZE.y;
		fragCoord.y = abs(RENDERSIZE.y-fragCoord.y);
	}
	fragCoord.x -= RENDERSIZE.x/2.;
	fragCoord.x /= 1.+sin(fragCoord.y/RENDERSIZE.y*3.14-3.10)*0.33;
	fragCoord.y += -(TIME)/speed;
	//fragCoord -= mod(fragCoord, 7.);
	
	vec2 p = fragCoord.xy / iResolution.xy;
	
	vec2 uv = p*vec2(iResolution.x/iResolution.y,1.0);
	
    vec2 TIME = iTime * speed * vec2(0);
    float q = fbm(uv * cloudscale * 0.5);
    
    //ridged noise shape
	float r = 0.0;
	uv *= cloudscale;
    uv -= q - TIME;
    float weight = 0.8;
    for (int i=0; i<8; i++){
		r += abs(weight*noise( uv ));
        uv = m*uv + TIME;
		weight *= 0.7;
    }
    
    //noise shape
	float f = 0.0;
    uv = p*vec2(iResolution.x/iResolution.y,1.0);
	uv *= cloudscale;
    uv -= q - TIME;
    weight = 0.7;
    for (int i=0; i<8; i++){
		f += weight*noise( uv );
        uv = m*uv + TIME;
		weight *= 0.6;
    }
    
    f *= r + f;
    
    //noise colour
    float c = 0.0;
    TIME *= 2.;
    uv = p*vec2(iResolution.x/iResolution.y,1.0);
	uv *= cloudscale*2.0;
    uv -= q - TIME;
    weight = 0.4;
    for (int i=0; i<7; i++){
		c += weight*noise( uv );
        uv = m*uv + TIME;
		weight *= 0.6;
    }
    
    //noise ridge colour
    float c1 = 0.0;
    TIME *= 3./2.;
    uv = p*vec2(iResolution.x/iResolution.y,1.0);
	uv *= cloudscale*3.0;
    uv -= q - TIME;
    weight = 0.4;
    for (int i=0; i<7; i++){
		c1 += abs(weight*noise( uv ));
        uv = m*uv + TIME;
		weight *= 0.6;
    }
	
    c += c1;
    
    vec3 skycolour = mix(skycolour1, skycolour1, p.y);
    vec3 cloudcolour = vec3(1.1, 1.1, 0.9) * clamp((clouddark + cloudlight*c), 0.0, 1.0);
   
    f = cloudcover + cloudalpha*f*r;
    
    vec3 result = mix(skycolour, clamp(skytint * skycolour + cloudcolour, 0.0, 1.0), clamp(f + c, 0.0, 1.0));
    
	fragColor = vec4( result*flip, 1.0 );
}