/*{
  "DESCRIPTION": "Barnsley Fern",
  "CREDIT": "P_Malin (ported from https://www.vertexshaderart.com/art/zHorsBAipg3PMpwaL)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 100000,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.42745098039215684,
    0.49019607843137253,
    0.5529411764705883,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 1124,
    "ORIGINAL_LIKES": 5,
    "ORIGINAL_DATE": {
      "$date": 1446554481737
    }
  }
}*/

// Barnsley Fern - @P_Malin
// https://en.wikipedia.org/wiki/Barnsley_fern

// hash function from https://www.shadertoy.com/view/4djSRW
float hash(float p)
{
 vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
 return fract(p2.x * p2.y * 95.4337);
}

void main()
{
   vec3 p = vec3( 0.01, 0.86, 0.93 ); // p = probability thresholds. Individual probabilities for each transform = 0.01, 0.85, 0.07, 0.07

   vec3 vColor = vec3( 0.0 );
   vec2 vPos = vec2( 0.0 );
   float fRandomSeed = vertexId + time;
   for ( int i=0; i<32; i++ )
    {
  float fSelection = hash( fRandomSeed );
       fRandomSeed += 12.3456;

       if ( fSelection < p.x )
        {
        vPos = vPos * mat2( 0.0, 0.0, 0.0, 0.16 ) + vec2( 0.0, 0.0 );
        vColor.r += 0.3;
        }
       else if ( fSelection < p.y )
        {
        float fRot = sin(time) * 0.01;
        vPos = vPos * mat2( 0.85, 0.04, -0.04, 0.85 ) * mat2( cos(fRot), sin(fRot), -sin(fRot), cos(fRot) ) + vec2( 0.0, 1.6 );
        vColor -= 0.005;
        }
       else if ( fSelection < p.z )
        {
        vPos = vPos * mat2( 0.20, -0.26, 0.23, 0.22 ) + vec2( 0.0, 1.6 );
        vColor.g += 0.05;
        }
       else
        {
        vPos = vPos * mat2( -0.15, 0.28, 0.26, 0.24 ) + vec2( 0.0, 0.44 );
        vColor.g += 0.1;
        }
    }

   vPos = vPos * 0.1 + vec2(0.0, -0.5);

   gl_PointSize = max( 1.0, resolution.x / 600.0 );
   gl_Position = vec4( vPos * vec2(1.0, resolution.x / resolution.y) , 0, 1 );

   v_color = vec4( vColor, 1.0 );
}