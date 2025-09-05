/*{
  "DESCRIPTION": "seascape",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/BnhvgAERQC5rcGRoZ)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
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
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 145,
    "ORIGINAL_DATE": {
      "$date": 1555887621705
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
float SCALE = 1.0;
float SIZE = floor( sqrt( vertexCount ) );
float TSCALE = 0.2 * 4096./vertexCount;
float MSCALE = 0.12 * 64.0/SIZE;

// sea
const int ITER_GEOMETRY = 3;
const int ITER_FRAGMENT = 5;
const float SEA_HEIGHT = 0.6;
const float SEA_CHOPPY = 4.0;
const float SEA_SPEED = 0.8;
const float SEA_FREQ = 0.16;
const vec3 SEA_BASE = vec3(0.1,0.19,0.22);
const vec3 SEA_WATER_COLOR = vec3(0.8,0.9,0.6);
#define SEA_TIME (1.0 + iTime * SEA_SPEED)
const mat2 octave_m = mat2(1.6,1.2,-1.2,1.6);

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
       0.54031230, -0.84147 );

float hash( vec2 p ) {
 float h = dot(p,vec2(127.1,311.7));
    return fract(sin(h)*43758.5453123);
}
float noise( in vec2 p ) {
    vec2 i = floor( p );
    vec2 f = fract( p );
 vec2 u = f*f*(3.0-2.0*f);
    return -1.0+2.0*mix( mix( hash( i + vec2(0.0,0.0) ),
        hash( i + vec2(1.0,0.0) ), u.x),
        mix( hash( i + vec2(0.0,1.0) ),
        hash( i + vec2(1.0,1.0) ), u.x), u.y);
}
float fbm( vec2 uv, float choppy )
{
    uv += noise(uv);
    vec2 wv = 1.0-abs(sin(uv));
    vec2 swv = abs(cos(uv));
    wv = mix(wv,swv,wv);
    return pow(1.0-pow(wv.x * wv.y,0.65),choppy);
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
  return vec3( (-SIZE/2.0 + x) * SPACING, fbm( vec2( x, y ) * TSCALE + trans, SEA_CHOPPY ) * SCALE, (-SIZE/2.0 + y) * SPACING );
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
  v_color = vec4(max( 0.0, 1.0 - p.z/24. ) );
}