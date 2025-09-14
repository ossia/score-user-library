/*{
  "DESCRIPTION": "first exp",
  "CREDIT": "rolf (ported from https://www.vertexshaderart.com/art/9dSN7fhb4hT8SrRor)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 4000,
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
    "ORIGINAL_VIEWS": 4,
    "ORIGINAL_DATE": {
      "$date": 1670958245211
    }
  }
}*/

#define tau 6.28318530718
#define res resolution
#define rot( x ) mat2( cos( x*tau ), -sin( x*tau ), sin( x*tau ), cos( x*tau ) )
#define pos gl_Position.xy
#define pSize gl_PointSize
#define id ( vertexId - vertexCount/2. )
#define cnt vertexCount
#define nsin( x ) ( sin( x )*.5 + .5 )
#define flip( x ) ( 1. - ( x ) )
#define inv( x ) ( 1. / ( x ) )

vec3 c = vec3( 0. );

vec3 hsv2rgb(vec3 c)
{
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
    gl_Position.xyzw = vec4( 0., 0., 0., 1. );

    pos = vec2( 0., 0. );
    float yoff = step( mod( vertexId, 2. ), 0.0 );
    float x = cnt;
    pos.x = 2.*( id + 0.5 )/( cnt/4.0 );

    float w = nsin( 2.*time + 4.*pos.x );
    pSize = 64. * w;
    pos.y = yoff*.5+.5*nsin( 2.*time + 32.*pos.x*.2*sin( time/2. )*2. );
        c = hsv2rgb( vec3( w/2., 1., 1. ) );
    pos += mouse;

    v_color = vec4( c, 1. );
}