/*
{
  "CATEGORIES" : [
    "Automatically Converted",
    "GLSLSandbox"
  ],
  "INPUTS" : [

  ],
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#42676.0"
}
*/


// Trinity
// By: Brandon Fogerty
// bfogerty at gmail dot com
// xdpixel.com
 
 
//"For God so loved the world, that he gave his only Son, 
// that whoever believes in him should not perish but have eternal life." (John 3:16)
    
// "Go therefore and make disciples of all nations, baptizing them in 
// the name of the Father and of the Son and of the Holy Spirit, 
// teaching them to observe all that I have commanded you. 
// And behold, I am with you always, to the end of the age." - King Jesus (Matthew 28:19-20)
 
#ifdef GL_ES
precision mediump float;
#endif
 
#extension GL_OES_standard_derivatives : enable
 
 
 
 
#define Resolution              RENDERSIZE
#define Time                    TIME
 
#define HorizontalAmplitude     0.30
#define VerticleAmplitude       0.20
#define HorizontalSpeed         0.90
#define VerticleSpeed           1.50
#define ParticleMinSize         1.76
#define ParticleMaxSize         1.61
#define ParticleBreathingSpeed      0.30
#define ParticleColorChangeSpeed    0.70
#define ParticleCount           2.0
#define ParticleColor1          vec3(9.0, 5.0, 3.0)
#define ParticleColor2          vec3(1.0, 3.0, 9.0)
 
 
float hash( float x )
{
    return fract( sin( x ) * 43758.5453 );
}
 
float noise( vec2 uv )  // Thanks Inigo Quilez
{
    vec3 x = vec3( uv.xy, 0.0 );
    
    vec3 p = floor( x );
    vec3 f = fract( x );
    
    f = f*f*(3.0 - 2.0*f);
    
    float offset = 57.0;
    
    float n = dot( p, vec3(1.0, offset, offset*2.0) );
    
    return mix( mix(    mix( hash( n + 0.0 ),       hash( n + 1.0 ), f.x ),
                        mix( hash( n + offset),     hash( n + offset+1.0), f.x ), f.y ),
                mix(    mix( hash( n + offset*2.0), hash( n + offset*2.0+1.0), f.x),
                        mix( hash( n + offset*3.0), hash( n + offset*3.0+1.0), f.x), f.y), f.z);
}
 
float snoise( vec2 uv )
{
    return noise( uv ) * 2.0 - 1.0;
}
 
 
float perlinNoise( vec2 uv )
{   
    float n =       noise( uv * 1.0 )   * 128.0 +
                noise( uv * 2.0 )   * 64.0 +
                noise( uv * 4.0 )   * 32.0 +
                noise( uv * 8.0 )   * 16.0 +
                noise( uv * 16.0 )  * 8.0 +
                noise( uv * 32.0 )  * 4.0 +
                noise( uv * 64.0 )  * 2.0 +
                noise( uv * 128.0 ) * 1.0;
    
    float noiseVal = n / ( 1.0 + 2.0 + 4.0 + 8.0 + 16.0 + 32.0 + 64.0 + 128.0 );
    noiseVal = abs(noiseVal * 2.0 - 1.0);
    
    return  noiseVal;
}
 
float fBm( vec2 uv, float lacunarity, float gain )
{
    float sum = 0.0;
    float amp = 7.0;
    
    for( int i = 0; i < 2; ++i )
    {
        sum += ( perlinNoise( uv ) ) * amp;
        amp *= gain;
        uv *= lacunarity;
    }
    
    return sum;
}
 
vec3 particles( vec2 pos )
{
    
    vec3 c = vec3( 0, 0, 0 );
    
    float noiseFactor = fBm( pos, 0.01, 0.1);
    
    for( float i = 1.0; i < ParticleCount+1.0; ++i )
    {
        float cs = cos( TIME * HorizontalSpeed * (i/ParticleCount) + noiseFactor ) * HorizontalAmplitude;
        float ss = sin( TIME * VerticleSpeed   * (i/ParticleCount) + noiseFactor ) * VerticleAmplitude;
        vec2 origin = vec2( cs , ss );
        
        float t = sin( TIME * ParticleBreathingSpeed * i ) * 0.5 + 0.5;
        float particleSize = mix( ParticleMinSize, ParticleMaxSize, t );
        float d = clamp( sin( length( pos - origin )  + particleSize ), 0.0, particleSize);
        
        float t2 = sin( TIME * ParticleColorChangeSpeed * i ) * 0.5 + 0.5;
        vec3 color = mix( ParticleColor1, ParticleColor2, t2 );
        c += color * pow( d, 10.0 );
    }
    
    return c;
}
 
 
float line( vec2 a, vec2 b, vec2 p )
{
    vec2 aTob = b - a;
    vec2 aTop = p - a;
    
    float t = dot( aTop, aTob ) / dot( aTob, aTob);
    
    t = clamp( t, 0.0, 1.0);
    
    float d = length( p - (a + aTob * t) );
    d = 1.0 / d;
    
    return clamp( d, 0.0, 1.0 );
}
 
 
void main( void ) {
 
    float aspectRatio = RENDERSIZE.x / RENDERSIZE.y;
    
    vec2 uv = ( gl_FragCoord.xy / RENDERSIZE.xy );
    
    vec2 signedUV = uv * 2.0 - 1.0;
    signedUV.x *= aspectRatio;
 
    float freqA = mix( 0.4, 1.2, sin(TIME + 30.0) * 0.5 + 0.5 );
    float freqB = mix( 0.4, 1.2, sin(TIME + 20.0) * 0.5 + 0.5 );
    float freqC = mix( 0.4, 1.2, sin(TIME + 10.0) * 0.5 + 0.5 );
    
    
    float scale = 100.0;
    const float v = 70.0;
    vec3 finalColor = vec3( 0.0 );
    
    finalColor = (particles( sin( abs(signedUV) ) ) * length(signedUV)) * 0.20;
    
    float t = line( vec2(-v, -v), vec2(0.0, v), signedUV * scale );
    finalColor += vec3( 8.0 * t, 2.0 * t, 4.0 * t) * freqA;
    t = line( vec2(0.0, v), vec2(v, -v), signedUV * scale );
    finalColor += vec3( 2.0 * t, 8.0 * t, 4.0 * t) * freqB;
    t = line( vec2(-v, -v), vec2(v, -v), signedUV * scale );
    finalColor += vec3( 2.0 * t, 4.0 * t, 8.0 * t) * freqC;
    
 
    scale = scale * 1.2;
    t = line( vec2(0.0, v * 0.2), vec2(0.0, -v * 0.8), signedUV * scale );
    finalColor += vec3( 8.0 * t, 4.0 * t, 2.0 * t) * 0.5;
    
    t = line( vec2(-v * 0.3, -v*0.1), vec2(v * 0.3, -v*0.1), signedUV * scale );
    finalColor += vec3( 8.0 * t, 4.0 * t, 2.0 * t) * 0.4;
 
    gl_FragColor = vec4( finalColor, 1.0 );
}