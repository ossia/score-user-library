/*
{
  "CATEGORIES" : [
    "Automatically Converted",
    "GLSLSandbox"
  ],
  "INPUTS" : [
    {
      "NAME" : "mouse",
      "TYPE" : "point2D",
      "MAX" : [
        1,
        1
      ],
      "MIN" : [
        0,
        0
      ]
    }
  ],
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#36403.0"
}
*/


#ifdef GL_ES
precision mediump float;
#endif

// Adapted from https://www.shadertoy.com/view/lt23D3


////////////////////////////////////////////////////////////////
// BOILERPLATE UTILITIES...................
const float pi = 3.14159;
const float pi2 = pi * 2.;

mat2 rot2D(float r)
{
    float c = cos(r), s = sin(r);
    return mat2(c, s, -s, c);
}
float nsin(float a){return .5+.5*sin(a);}
float ncos(float a){return .5+.5*cos(a);}
vec3 saturate(vec3 a){return clamp(a,0.,1.);}
float opS( float d2, float d1 ){return max(-d1,d2);}
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
float rand(float n){
 	return fract(cos(n*89.42)*343.42);
}
float dtoa(float d, float amount)
{
    return clamp(1.0 / (clamp(d, 1.0/amount, 1.0)*amount), 0.,1.);
}
float sdAxisAlignedRect(vec2 uv, vec2 tl, vec2 br)
{
    vec2 d = max(tl-uv, uv-br);
    return length(max(vec2(0.0), d)) + min(0.0, max(d.x, d.y));
}

// 0-1 1-0
float smoothstep4(float e1, float e2, float e3, float e4, float val)
{
    return min(smoothstep(e1,e2,val), 1.-smoothstep(e3,e4,val));
}

// hash & simplex noise from https://www.shadertoy.com/view/Msf3WH
vec2 hash( vec2 p )
{
	p = vec2( dot(p,vec2(127.1,311.7)),
			  dot(p,vec2(269.5,183.3)) );
	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}
// returns -.5 to 1.5. i think.
float noise( in vec2 p )
{
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;

	vec2 i = floor( p + (p.x+p.y)*K1 );
	
    vec2 a = p - i + (i.x+i.y)*K2;
    vec2 o = (a.x>a.y) ? vec2(1.0,0.0) : vec2(0.0,1.0); //vec2 of = 0.5 + 0.5*vec2(sign(a.x-a.y), sign(a.y-a.x));
    vec2 b = a - o + K2;
	vec2 c = a - 1.0 + 2.0*K2;

    vec3 h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );

	vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));

    return dot( n, vec3(70.0) );	
}
float noise01(vec2 p)
{
    return clamp((noise(p)+.5)*.5, 0.,1.);
}


////////////////////////////////////////////////////////////////
// APP CODE ...................

vec3 colorAxisAlignedBrushStroke(vec2 uv, vec2 uvPaper, vec3 inpColor, vec4 brushColor, vec2 p1, vec2 p2)
{
    // how far along is this point in the line. will come in handy.
    vec2 posInLine = smoothstep(p1, p2, uv);//(uv-p1)/(p2-p1);

    // wobble it around, humanize
    float wobbleAmplitude = 0.13;
    uv.x += sin(posInLine.y * pi2 * 0.2) * wobbleAmplitude;

    // distance to geometry
    float d = sdAxisAlignedRect(uv, p1, vec2(p1.x, p2.y));
    d -= abs(p1.x - p2.x) * 0.5;// rounds out the end.
    
    // warp the position-in-line, to control the curve of the brush falloff.
    posInLine = pow(posInLine, vec2((nsin(TIME * 0.5) * 2.) + 0.3));

    // brush stroke fibers effect.
    float strokeStrength = dtoa(d, 100.);
    float strokeAlpha = 0.
        + noise01((p2-uv) * vec2(min(RENDERSIZE.y,RENDERSIZE.x)*0.25, 1.))// high freq fibers
        + noise01((p2-uv) * vec2(79., 1.))// smooth brush texture. lots of room for variation here, also layering.
        + noise01((p2-uv) * vec2(14., 1.))// low freq noise, gives more variation
        ;
    strokeAlpha *= 0.66;
    strokeAlpha = strokeAlpha * strokeStrength;
    strokeAlpha = strokeAlpha - (1.-posInLine.y);
    strokeAlpha = (1.-posInLine.y) - (strokeAlpha * (1.-posInLine.y));

    // fill texture. todo: better curve, more round?
    const float inkOpacity = 0.85;
    float fillAlpha = (dtoa(abs(d), 90.) * (1.-inkOpacity)) + inkOpacity;

    // todo: splotches ?
    
    // paper bleed effect.
    float amt = 140. + (rand(uvPaper.y) * 30.) + (rand(uvPaper.x) * 30.);
    

    float alpha = fillAlpha * strokeAlpha * brushColor.a * dtoa(d, amt);
    alpha = clamp(alpha, 0.,1.);
    return mix(inpColor, brushColor.rgb, alpha);
}

vec3 colorBrushStroke(vec2 uv, vec3 inpColor, vec4 brushColor, vec2 p1, vec2 p2, float lineWidth)
{
    // flatten the line to be axis-aligned.
    vec2 rectDimensions = p2 - p1;
    float angle = atan(rectDimensions.x, rectDimensions.y);
    mat2 rotMat = rot2D(-angle);
    p1 *= rotMat;
    p2 *= rotMat;
    float halfLineWidth = lineWidth / 2.;
    p1 -= halfLineWidth;
    p2 += halfLineWidth;
	vec3 ret = colorAxisAlignedBrushStroke(uv * rotMat, uv, inpColor, brushColor, p1, p2);
    // todo: interaction between strokes, smearing like my other shader
    return ret;
}

void main( void )
{
	vec2 uv = (gl_FragCoord.xy / RENDERSIZE.y * 2.0) - 1.;
    vec2 mymouse = (mouse.xy / RENDERSIZE.y * 2.0) - 1.;
    
    vec3 col = vec3(1.,1.,0.86);// bg
    float dist;
    
    // black stroke
    col = colorBrushStroke(uv, col, vec4(vec3(.4 * cos(TIME),.1 * cos(TIME),0),.8),// red fixed line
                           vec2(1.0, 0.27 * sin(TIME)),
                           vec2(-0.6 * cos(TIME), -.6 * cos(TIME)), 0.1);

    col = colorBrushStroke(uv, col, vec4(vec3(0.),.8),// black fixed line
                           vec2(.6, -.8),
                           vec2(2.3, .2),
                           0.1);

    if(mouse.x == 0.)
        mymouse = vec2(1.1,.8);
    col = colorBrushStroke(uv, col, vec4(vec3(0.),.9),// black movable line
                           vec2(-0.4, 0.0),
                           mymouse,0.3);

    // grain
    col.rgb += (rand(uv)-.5)*.08 * cos(TIME);
    col.rgb = saturate(col.rgb);

    uv -= 1.0;// vignette
	float vignetteAmt = 1.-dot(uv*0.5,uv* 0.12);
    col *= vignetteAmt;
    
    
    gl_FragColor = vec4(col, 1.);
}
