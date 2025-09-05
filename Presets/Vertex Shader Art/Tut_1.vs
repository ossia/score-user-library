/*{
  "DESCRIPTION": "Tut 1",
  "CREDIT": "randomstarz (ported from https://www.vertexshaderart.com/art/LHj56pPH8J6ufctmP)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [],
  "POINT_COUNT": 100,
  "PRIMITIVE_MODE": "POINTS",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    1,
    1,
    1,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1551412788519
    }
  }
}*/

void main ()
{
   gl_PointSize = 10.0;

   float across = 10.;

   //float x = ( vertexId / vertexCount ) + 0.1;

   float x = mod( vertexId, across );
   float y = floor( vertexId / across );

   x = x - across / 2.;
   y = y - across / 2.;

   x /= across;
   y /= across;

   gl_Position = vec4( x, y, 0, 1 );

 v_color = vec4( 0.1, 0.4, 0.8, 1.0 );
}