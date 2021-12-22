/*
{
  "CATEGORIES" : [
    "Automatically Converted",
    "GLSLSandbox"
  ],
  "ISFVSN" : "2",
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#50854.0"
}
*/


/*
 * Original shader from: https://www.shadertoy.com/view/XtyfDc
 */

#ifdef GL_ES
precision mediump float;
#endif

// glslsandbox uniforms

// shadertoy globals
float iTime = 0.0;
vec3  iResolution = vec3(0.0);

// --------[ Original ShaderToy begins here ]---------- //
// variant of https://shadertoy.com/view/4lGfDc

#define S(r)  smoothstep(  9./R.y, 0., abs( U.x -r ) -.1 )
void mainImage(inout vec4 O, vec2 u) {
    vec2 R = iResolution.xy,
         U = u+u - R;
    U =  length(U+U)/R.y    /* .955 = 3/pi  1.05 = pi/3 */
         *cos( ( mod( .955*atan(U.y,U.x) - iTime ,1.5) - .72 ) *1.55 -vec2(0,1.97));
    U.x+U.y < 1.85 ? O += mix( .5* S(.5), S(.7), .5+.5*U.y ) : O ;
}
// --------[ Original ShaderToy ends here ]---------- //

void main(void)
{
    iTime = TIME;
    iResolution = vec3(RENDERSIZE, 0.0);

    gl_FragColor.rgb = vec3(0.0);
    mainImage(gl_FragColor, gl_FragCoord.xy);
    gl_FragColor.a = 1.0;
}