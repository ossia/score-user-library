/*
{
  "CATEGORIES" : [
    "Automatically Converted",
    "GLSLSandbox"
  ],
  "INPUTS" : [

  ],
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#54307.0"
}
*/


/*
 * Original shader from: https://www.shadertoy.com/view/XsXXDX
 */

#ifdef GL_ES
precision mediump float;
#endif

// glslsandbox uniforms

// shadertoy globals
#define iTime TIME
#define iResolution RENDERSIZE

// --------[ Original ShaderToy begins here ]---------- //
// Subpixels antialiased markers
// Nicolas P. Rougier (http://www.loria.fr/~rougier)
// Released under BSD license.

const float M_PI = 3.14159265358979323846;
const float SQRT_2 = 1.4142135623730951;


vec4 stroke(float distance, float linewidth, float antialias, vec4 stroke)
{
    vec4 frag_color;
    float t = linewidth/2.0 - antialias;
    float signed_distance = distance;
    float border_distance = abs(signed_distance) - t;
    float alpha = border_distance/antialias;
    alpha = exp(-alpha*alpha);

    if( border_distance > (linewidth/2.0 + antialias) )
        discard;
    else if( border_distance < 0.0 )
        frag_color = stroke;
    else
        frag_color = vec4(stroke.rgb*alpha, 1.);

    return frag_color;
}

vec4 filled(float distance, float linewidth, float antialias, vec4 fill)
{
    vec4 frag_color;
    float t = linewidth/2.0 - antialias;
    float signed_distance = distance;
    float border_distance = abs(signed_distance) - t;
    float alpha = border_distance/antialias;
    alpha = exp(-alpha*alpha);

    // Within linestroke
    if( border_distance < 0.0 )
        frag_color = fill;
    // Within shape
    else if( signed_distance < 0.0 )
        frag_color = fill;
    else
        // Outside shape
        if( border_distance > (linewidth/2.0 + antialias) )
            discard;
        else // Line stroke exterior border
            frag_color = vec4(fill.rgb*alpha, 1.0);

    return frag_color;
}

vec4 outline(float distance, float linewidth, float antialias, vec4 stroke, vec4 fill)
{
    vec4 frag_color;
    float t = linewidth/2.0 - antialias;
    float signed_distance = distance;
    float border_distance = abs(signed_distance) - t;
    float alpha = border_distance/antialias;
    alpha = exp(-alpha*alpha);

    // Within linestroke
    if( border_distance < 0.0 )
        frag_color = stroke;
    else if( signed_distance < 0.0 )
        // Inside shape
        if( border_distance > (linewidth/2.0 + antialias) )
            frag_color = fill;
        else // Line stroke interior border
            frag_color = mix(fill, stroke, alpha);
    else
        // Outide shape
        if( border_distance > (linewidth/2.0 + antialias) )
            discard;
        else // Line stroke exterior border
            frag_color = vec4(stroke.rgb*alpha, 1.0);

    return frag_color;
}


float marker_T(vec2 P, float size)
{
   float x = -P.y;
   float y = P.x;

   float r1 = max(abs(x -size/3. + size/3.), abs(x - size/3. - size/3.));
   float r2 = max(abs(y - size/3.), abs(y + size/3.));
   float r3 = max(abs(x), abs(y));
   float r = max(min(r1,r2),r3);
   r -= size/2.;
   return r;
}

float marker_check(vec2 P, float size)
{
    float x = SQRT_2/2. * (P.x - P.y);
    float y = SQRT_2/2. * (P.x + P.y);

    float r1 = max(abs(x - 2.*size/3.), abs(x - 1.*size/3.));
    float r2 = max(abs(y - 2.*size/3.), abs(y - size/3.));
    float r3 = max(abs(x),max(abs(x-size/3.), abs(y)));
    float r = max(min(r1,r2),r3);
    r -= size/2.;
    return r;
}

float marker_cross(vec2 P, float size)
{
   float x = SQRT_2/2. * (P.x - P.y);
   float y = SQRT_2/2. * (P.x + P.y);

    float r1 = max(abs(x - size/3.), abs(x + size/3.));
    float r2 = max(abs(y - size/3.), abs(y + size/3.));
    float r3 = max(abs(x), abs(y));
    float r = max(min(r1,r2),r3);
    r -= size/2.;
    return r;
}


float marker_clobber(vec2 P, float size)
{
    const float t1 = -M_PI/2.;
    vec2  c1 = 0.25*vec2(cos(t1),sin(t1));

    const float t2 = t1+2.*M_PI/3.;
    vec2  c2 = 0.25*vec2(cos(t2),sin(t2));

    const float t3 = t2+2.*M_PI/3.;
    vec2  c3 = 0.25*vec2(cos(t3),sin(t3));

    float r1 = length( P - c1*size) - size/3.5;
    float r2 = length( P - c2*size) - size/3.5;
    float r3 = length( P - c3*size) - size/3.5;
    return min(min(r1,r2),r3);
}


float marker_asterisk(vec2 P, float size)
{
   float x = SQRT_2/2. * (P.x - P.y);
   float y = SQRT_2/2. * (P.x + P.y);

   float r1 = max(abs(x)- size/2., abs(y)- size/10.);
   float r2 = max(abs(y)- size/2., abs(x)- size/10.);
   float r3 = max(abs(P.x)- size/2., abs(P.y)- size/10.);
   float r4 = max(abs(P.y)- size/2., abs(P.x)- size/10.);
   return min( min(r1,r2), min(r3,r4));
}


float marker_chevron(vec2 P, float size)
{
    float x = 1./SQRT_2 * (P.x - P.y);
    float y = 1./SQRT_2 * (P.x + P.y);
    float r1 = max(abs(x),        abs(y))        - size/3.;
    float r2 = max(abs(x-size/3.), abs(y-size/3.)) - size/3.;
    return max(r1,-r2);
}

float marker_ring(vec2 P, float size)
{
    float r1 = length(P) - size/2.;
    float r2 = length(P) - size/4.;
    return max(r1,-r2);
}

float marker_infinity(vec2 P, float size)
{
    const vec2 c1 = vec2(+0.25, 0.00);
    const vec2 c2 = vec2(-0.25, 0.00);
    float r1 = length(P-c1*size) - size/3.;
    float r2 = length(P-c1*size) - size/7.;
    float r3 = length(P-c2*size) - size/3.;
    float r4 = length(P-c2*size) - size/7.;
    return min( max(r1,-r2), max(r3,-r4));
}

float marker_tag(vec2 P, float size)
{
    float x = -P.x;
    float y = P.y;
    float r1 = max(abs(x)- size/2., abs(y)- size/6.);
    float r2 = abs(x-size/1.5)+abs(y)-size;
    return max(r1,.75*r2);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{ fragColor = vec4(0., 0., 0., 1.);
    const float linewidth = 1.5;
    const float antialias = 1.0;

    const float rows = 4.0;
    const float cols = 9.0;
    float body = min(iResolution.x/cols, iResolution.y/rows) / SQRT_2;
    vec2 texcoord = vec2(fragCoord.x, iResolution.y-fragCoord.y);
    vec2 size   = iResolution.xy / vec2(cols,rows);
    vec2 center = (floor(texcoord/size) + vec2(0.5,0.5)) * size;
    texcoord -= center;

    float theta = (iTime/2.0);

    float cos_theta = cos(theta);
    float sin_theta = sin(theta);
    texcoord = vec2(cos_theta*texcoord.x - sin_theta*texcoord.y,
                    sin_theta*texcoord.x + cos_theta*texcoord.y);

    float d;

    float s = size.x/SQRT_2;
    
    if (fragCoord.x < 1.*size.x)
        d = marker_T(texcoord, s);

    else if (fragCoord.x < 2.*size.x)
        d = marker_check(texcoord, s);

    else if (fragCoord.x < 3.*size.x)
        d = marker_cross(texcoord, s);
        
    else if (fragCoord.x < 4.*size.x)
        d = marker_clobber(texcoord, s);

    else if (fragCoord.x < 5.*size.x)
        d = marker_asterisk(texcoord, s);

    else if (fragCoord.x < 6.*size.x)
        d = marker_chevron(texcoord, s);

    else if (fragCoord.x < 7.*size.x)
        d = marker_ring(texcoord, s);

    else if (fragCoord.x < 8.*size.x)
        d = marker_infinity(texcoord, s);

    else if (fragCoord.x < 9.*size.x)
        d = marker_tag(texcoord, s);


    if (fragCoord.y < 1.*size.y)
        fragColor = stroke(d, linewidth, antialias, vec4(1,1,1,1));
    else if (fragCoord.y < 2.*size.y)
        fragColor = outline(d, linewidth, antialias, vec4(1,1,1,1), vec4(.25,.25,.25,1) );
    else if (fragCoord.y < 3.*size.y)
        fragColor = outline(d, linewidth, antialias, vec4(1,1,1,1), vec4(.75,.75,.75,1) );
    else
        fragColor = filled(d, linewidth, antialias, vec4(1,1,1,1));

        }
// --------[ Original ShaderToy ends here ]---------- //

void main(void)
{
    mainImage(gl_FragColor, gl_FragCoord.xy);
}