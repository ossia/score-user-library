/*{
  "DESCRIPTION": "Simple Fractal wip",
  "CREDIT": "trip-les-ix (ported from https://www.vertexshaderart.com/art/BsrLb5e2Fujc6RvJf)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Abstract"
  ],
  "POINT_COUNT": 65536,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 158,
    "ORIGINAL_DATE": {
      "$date": 1568768683451
    }
  }
}*/

// Simple Fractal - @P_Malin

void main()
{
   float fRotation = time * 0.5;
   vec2 vTranslation = vec2( 0.2, 0.2 );
   float fScale = 0.6;

   float fSinRot = sin(fRotation);
   float fCosRot = cos(fRotation);

   mat3 m = mat3( fCosRot * fScale, fSinRot * fScale, vTranslation.x, -fSinRot * fScale, fCosRot * fScale, vTranslation.y, 0.0, 0.0, 1.0 );

   vec2 vPos = vec2( 0.0 );
   vec2 vMin = vec2( 100.0 );
  float fPassId = vertexId;

   for ( int i=0; i<8; i++ )
    {
     vPos = (vec3(vPos, 1.0) * m).xy;

       fPassId = fPassId / 4.0;

       if ( fract( fPassId * 2.0 ) < 0.5 ) vPos.x = -vPos.x;
       if ( fract( fPassId ) < 0.5 ) vPos.y = -vPos.y;
       fPassId = floor( fPassId );

       vMin = min( vMin, abs( vPos ) );
    }

   gl_PointSize = 6.0;
   gl_Position = vec4(vPos * vec2( 1.0, resolution.x / resolution.y) , 1.0/vertexId, 1);

   vec3 vColor;
   vColor.x = sin( vMin.x * 10.0 + time * 1.234 ) * 0.5 + 0.5;
   vColor.y = sin( vMin.y * 10.0 + time * 2.345 ) * 0.5 + 0.5;
   vColor.z = sin( (vMin.x + vMin.y) * 5.0 + time * 3.456 ) * 0.5 + 0.5;

   vColor = normalize(vColor);

   vColor = 1.0 - exp2( vColor * -length( vMin ) * 2.0 );
   v_color = vec4( vColor, 0.0 );
}