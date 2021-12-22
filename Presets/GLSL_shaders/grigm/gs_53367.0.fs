/*
{
  "CATEGORIES" : [
    "Automatically Converted",
    "GLSLSandbox"
  ],
  "INPUTS" : [

  ],
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#53367.0"
}
*/


/*
 * Original shader from: https://www.shadertoy.com/view/ltjGDd
 */

#ifdef GL_ES
precision mediump float;
#endif

// glslsandbox uniforms

// shadertoy globals
#define iTime TIME
#define iResolution RENDERSIZE
const vec4  iMouse = vec4(0.0);

// --------[ Original ShaderToy begins here ]---------- //
// Fun with spherical lights, area shadows, occlusion and reflections.
// Sphere and trace functions by inigo quilez, http://www.iquilezles.org

#define BIAS 0.0001
#define PI 3.1415927
#define SEED 4.

float sphIntersect( in vec3 ro, in vec3 rd, in vec4 sph )
{
  vec3 oc = ro - sph.xyz;
  float b = dot( oc, rd );
  float c = dot( oc, oc ) - sph.w*sph.w;
  float h = b*b - c;
  if( h<0.0 ) return -1.0;
  return -b - sqrt( h );
}

float sphOcclusion( in vec3 pos, in vec3 nor, in vec4 sph )
{
    vec3  r = sph.xyz - pos;
    float l = length(r);
    float d = dot(nor,r);
    float res = d;

    if( d<sph.w ) res = pow(clamp((d+sph.w)/(2.0*sph.w),0.0,1.0),1.5)*sph.w;
    
    return clamp( res*(sph.w*sph.w)/(l*l*l), 0.0, 1.0 );

}

float sphAreaShadow( vec3 P, in vec4 L, vec4 sph )
{
  vec3 ld = L.xyz - P;
  vec3 oc = sph.xyz - P;
  float r = sph.w - BIAS;
  
  float d1 = sqrt(dot(ld, ld));
  float d2 = sqrt(dot(oc, oc));
  
  if (d1 - L.w / 2. < d2 - r) return 1.;
  
  float ls1 = L.w / d1;
  float ls2 = r / d2;

  float in1 = sqrt(1.0 - ls1 * ls1);
  float in2 = sqrt(1.0 - ls2 * ls2);
  
  if (in1 * d1 < in2 * d2) return 1.;
  
  vec3 v1 = ld / d1;
  vec3 v2 = oc / d2;
  float ilm = dot(v1, v2);
  
  if (ilm < in1 * in2 - ls1 * ls2) return 1.0;
  
  float g = length( cross(v1, v2) );
  
  float th = clamp((in2 - in1 * ilm) * (d1 / L.w) / g, -1.0, 1.0);
  float ph = clamp((in1 - in2 * ilm) * (d2 / r) / g, -1.0, 1.0);
  
  float sh = acos(th) - th * sqrt(1.0 - th * th) 
           + (acos(ph) - ph * sqrt(1.0 - ph * ph))
           * ilm * ls2 * ls2 / (ls1 * ls1);
  
  return 1.0 - sh / PI;
}


//-------------------------------------------------------------------------------------------
const int SPH = 27; //3x3x3

vec4 sphere[SPH];
vec4 L = vec4(0.);

vec3 rand3( float x, float seed )
{ 
  float f = x+seed;
  return fract( PI*sin( vec3(f,f+5.33,f+7.7)) );
}

float areaShadow( in vec3 P )
{
  float s = 1.0;
  for( int i=0; i<SPH; i++ )
    s = min( s, sphAreaShadow(P, L, sphere[i] ) );
  return s;           
}

vec3 reflections( vec3 P, vec3 R, vec3 tint, int iid )
{
  float t = 1e20;

  vec3 s = vec3(R.y < 0. ? 1.-sqrt(-R.y/(P.y+1.)) : 1.); // P.y+1 floor pos
  for( int i=0; i<SPH; i++ )
  {    
    float h = sphIntersect( P, R, sphere[i] );
    if( h>0.0 && h<t )
    {
      s = i == iid ? tint * 2. : vec3(0.);
      t = h;
    }
  }     
  return max( vec3(0.), s);           
}

float occlusion( vec3 P, vec3 N )
{
  float s = 1.0;
  for( int i=0; i<SPH; i++ )
    s *= 1.0 - sphOcclusion( P, N, sphere[i] ); 
  return s;           
}

float sphLight( vec3 P, vec3 N, vec4 L)
{
  vec3 oc = L.xyz  - P;
  float dst = sqrt( dot( oc, oc ));
  vec3 dir = oc / dst;
  
  float c = dot( N, dir );
  float s = L.w  / dst;
    
  return max(0., c * s);
}
  
//-------------------------------------------------------------------------------------------

vec3 shade( vec3 I, vec3 P, vec3 N, float id, float iid )
{
  vec3 base = rand3( id, SEED );
  vec3 wash = mix( vec3(0.9), base, 0.4);
  vec3 hero = rand3( iid, SEED );
  
  vec3 ref = reflections( P, I - 2.*(dot(I,N))*N, hero, int(iid) );
  float occ = occlusion( P, N );
  float ocf = 1.-sqrt((0.5 + 0.5*-N.y)/(P.y+1.25))*.5; //floor occusion. 1.25 floor P.
  float fre = clamp( 1. + dot( I, N), 0., 1.); fre = (0.01+0.4*pow(fre,3.5));
  float lgh = sphLight( P, N, L) *  areaShadow( P );
  float inc = ( id == iid ? 1.0 : 0.0 );
   
  // Env light
  vec3 C = wash * occ * ocf * .2;
  
  // Sphere light
  C += ( inc + lgh * 1.3 ) * hero;

  // Reflections
  C = mix( C, ref, fre );
  
  return C;
}    

vec3 trace( vec3 E, vec3 I, vec3 C, float px, float iid )
{
  float t = 1e20;
  float id  = -1.0;
  vec4  obj = vec4(0.);
  for( int i=0; i<SPH; i++ )
  {
    vec4 sph = sphere[i];
    float h = sphIntersect( E, I, sph ); 
    if( h>0.0 && h<t ) 
    {
      t = h;
      obj = sph;
      id = float(i);
    }
  }
              
  if( id>-0.5 )
  {
    vec3 P = E + t*I;
    vec3 N = normalize(P-obj.xyz);
    C = shade( I, P, N, id, iid  );
  }

  return C;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = (2.0*fragCoord.xy-iResolution.xy)/iResolution.y;
    vec2 m = step(0.0001,iMouse.z) * iMouse.xy/iResolution.xy;
    
    //-----------------------------------------------------
    
    float TIME = iTime;
    float an = 0.3*TIME - 7.0*m.x;
    float sec = mod(TIME,1.);
    
    float spI = floor(mod(TIME,float(SPH)));

    //-----------------------------------------------------
    for( int i=0; i<SPH; i++ )
    {
      float ra = 0.4;
      float id = float(i);
      sphere[i] = vec4( mod( id, 3.0) - 1.0,
                        mod( floor( id/3.0 ), 3.0 ) - .55,
                        floor( id/9.0 )-1.0, ra );

      if( i == int(spI) )
      {
        sphere[i].w += 0.025 * sin(sec*50.) / sqrt(sec) * ( 1.-sqrt(sec));
        L = sphere[i];
      }
    }

    //-----------------------------------------------------
    
    float fov = 1.8;
    vec3 E = vec3( 3.5*sin(an), 2.0, 3.5*cos(an));
    vec3 V = normalize( -E );
    vec3 uu = normalize( cross( V, vec3(0., 1., 0.)));
    vec3 vv = normalize( cross( uu, V));
    vec3 I = normalize( p.x*uu + p.y*vv + fov*V );

    float px = 1.0*(2.0/iResolution.y)*(1.0/fov);


    //-----------------------------------------------------
    
    vec3 C = vec3(1.);

    float tmin = 1e20;
    float t = -(1.0+E.y)/I.y;
    if( t>0.0 )
    {
        tmin = t;
        vec3 pos = E + t*I;
        vec3 nor = vec3(0.0,1.0,0.0);
        C = shade( I, pos, nor, -1.0, spI );
    }    
    
    C = trace( E, I, C, px, spI );
    
    // post
    C = pow( C, vec3(0.41545) );   
    C *= 0.5 + 0.5*pow(18.0*q.x*q.y*(1.0-q.x)*(1.0-q.y),0.12);

    fragColor = vec4( C, 1. );
}

// --------[ Original ShaderToy ends here ]---------- //

void main(void)
{
    mainImage(gl_FragColor, gl_FragCoord.xy);
}