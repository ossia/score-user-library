/*{
    "CATEGORIES": [
        "Noise",
        "Utility"
    ],
    "CREDIT": "Tuxic",
    "DESCRIPTION": "generates a basic voronoi cell noise",
    "INPUTS": [
        {
            "DEFAULT": 12.9898,
            "MAX": 100,
            "MIN": 0,
            "NAME": "seed",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0.75,
            "MAX": 1,
            "MIN": 0,
            "NAME": "iregularity",
            "TYPE": "float"
        },
        {
            "DEFAULT": 0,
            "MAX": 1,
            "MIN": 0,
            "NAME": "blur",
            "TYPE": "float"
        },
        {
            "DEFAULT": 10,
            "MAX": 100,
            "MIN": 0,
            "NAME": "scale",
            "TYPE": "float"
        }
    ],
    "ISFVSN": "2"
}
*/

//	<https://www.shadertoy.com/view/Xd23Dh>
//	by inigo quilez <http://iquilezles.org/www/articles/voronoise/voronoise.htm>
//

vec3 hash3( vec2 p ){
    vec3 q = vec3( dot(p,vec2(127.1,311.7)), 
				   dot(p,vec2(269.5,183.3)), 
				   dot(p,vec2(419.2,371.9)) );
	return fract(sin(q)*43758.5453 * seed);
}

float iqnoise( in vec2 x, float u, float v ){
    vec2 p = floor(x);
    vec2 f = fract(x);
		
	float k = 1.0+63.0*pow(1.0-v,4.0);
	
	float va = 0.0;
	float wt = 0.0;
    for( int j=-2; j<=2; j++ )
    for( int i=-2; i<=2; i++ )
    {
        vec2 g = vec2( float(i),float(j) );
		vec3 o = hash3( p + g )*vec3(u,u,1.0);
		vec2 r = g - f + o.xy;
		float d = dot(r,r);
		float ww = pow( 1.0-smoothstep(0.0,1.414,sqrt(d)), k );
		va += o.z*ww;
		wt += ww;
    }
	
    return va/wt;
}

void main()	{
	gl_FragColor = vec4(vec3(iqnoise(isf_FragNormCoord.xy * scale, iregularity, blur)), 1);
}
