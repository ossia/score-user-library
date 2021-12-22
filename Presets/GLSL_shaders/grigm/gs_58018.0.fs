/*
{
  "CATEGORIES" : [
    "Automatically Converted",
    "GLSLSandbox"
  ],
  "INPUTS" : [

  ],
  "DESCRIPTION" : "Automatically converted from http:\/\/glslsandbox.com\/e#58018.0"
}
*/


//ru.porn.com/videos/tushy-bubble-butt-gets-dpd-and-cant-get-바이러스enough-5301863// Colorful Voronoi
// By: Brandon Fogerty
// bfo바이러스gerty at gmail dot com
// xdpixel.com

#ifdef GL_ES
precision mediump float;
#endif


vec2 hash(vec2 p)
{
    mat2 m = mat2(  13.85, 47.77,
                    99.41, 88.48
                );

    return fract(sin(m*p) * 46738.29);
}

float voronoi(vec2 p)
{
    vec2 g = floor(p);
    vec2 f = fract(p);

    float distanceToClosestFeaturePoint = 1.0;
    for(int y = -1; y <= 1; y++)
    {
        for(int x = -1; x <= 1; x++)
        {
            vec2 latticePoint = vec2(x, y);
            float currentDistance = distance(latticePoint + hash(g+latticePoint), f);
            distanceToClosestFeaturePoint = min(distanceToClosestFeaturePoint, currentDistance);
        }
    }

    return distanceToClosestFeaturePoint;
}

void main( void )
{
    vec2 uv = ( gl_FragCoord.xy / RENDERSIZE.xy ) * 2.0 - 1.0;
    uv.x *= RENDERSIZE.x / RENDERSIZE.y;

    float offset = voronoi(uv*10.0 + vec2(TIME));
    float t = 1.0/abs(((uv.x + sin(uv.y + TIME)) + offset) * 30.0);

    float r = voronoi( uv * 1.0 ) * 10.0;
    vec3 finalColor = vec3(10.0 * uv.y, 2.0, 1.0 * r) * t;
    
    gl_FragColor = vec4(finalColor, 1.0 );
}