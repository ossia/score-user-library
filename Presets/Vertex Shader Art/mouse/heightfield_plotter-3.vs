/*{
  "DESCRIPTION": "heightfield plotter",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/jsKeJ8QviCT2KuxC4)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 16384,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Mouse", "NAME": "mouse", "TYPE": "point2D", "DEFAULT": [0.0, 0.0], "MIN": [0.0, 0.0], "MAX": [1.0, 1.0] } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 183,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1538391011421
    }
  }
}*/

// classic retro effect
// rotate and scale by moving mouse
//
// pixel shader version: https://www.shadertoy.com/view/lt2SWc
// (a little slower)
//
// update:
// enlarged points for better visibility
//

#define POINTSIZE 2.0
float SCALE = 2.0 * (mouse.y+1.0);
float SIZE = floor( sqrt( vertexCount ) );
float TSCALE = 0.2 * 4096./vertexCount;
float MSCALE = 0.12 * 64.0/SIZE;

vec3 rotateY( vec3 p, float a )
{
    float sa = sin(a);
    float ca = cos(a);
    vec3 r;
    r.x = ca*p.x + sa*p.z;
    r.y = p.y;
    r.z = -sa*p.x + ca*p.z;
    return r;
}

// terrain function from mars shader by reider
// https://www.shadertoy.com/view/XdsGWH
const mat2 mr = mat2 (0.84147, 0.54030,
       0.54030, -0.84147 );
float hash( in float n )
{
 return fract(sin(n)*43758.5453);
}
float noise(in vec2 x)
{
 vec2 p = floor(x);
 vec2 f = fract(x);

 f = f*f*(3.0-1.0*f);
 float n = p.x + p.y*57.0;

 float res = mix(mix( hash(n+ 0.0), hash(n+ 1.0),f.x),
     mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);
 return res;
}
float fbm( in vec2 p )
{
 float f;
 f = 0.5000*noise( p ); p = mr*p*2.02;
 f += 0.2500*noise( p ); p = mr*p*2.33;
 f += 0.1250*noise( p ); p = mr*p*2.01;
 f += 0.0625*noise( p ); p = mr*p*5.21;

 return f/(0.9375)*smoothstep( 260., 768., p.y ); // flat at beginning
}

vec3 GetPoint( float vertexid )
{
  float SPACING = 16.0 / SIZE;
  float x = mod( vertexid, SIZE );
  if (x==SIZE-1.) // last in 'line'
  {
   //x = SIZE-2.; // equals previous
  }
  float y = floor( vertexid / SIZE );
  if (mod(y,2.)>0.0)
  {
    // odd - change direction
    x = SIZE - 1. - x;
  }
  vec2 trans = vec2( time * 16., time * 23.0 ) * MSCALE;
  return vec3( (-SIZE/2.0 + x) * SPACING, fbm( vec2( x, y ) * TSCALE + trans ) * SCALE, (-SIZE/2.0 + y) * SPACING );
}

void main()
{
  if (mod(SIZE,2.)>0.) SIZE += 1.; // need even number of points on side
  vec3 p = GetPoint( vertexId );
  float fov = 1.1;
  p = rotateY( p, -mouse.x*2.0 );
  float origz = p.z;
  p += vec3( 0.0, -5.0, 15.0 );
  gl_Position = vec4( p.xy*fov, 1.0/(p.z-0.0), p.z );
  gl_PointSize = POINTSIZE;
  v_color = vec4(max( 0.0, 1.0 - p.z/244. ) );
}