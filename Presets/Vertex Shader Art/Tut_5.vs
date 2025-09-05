/*{
  "DESCRIPTION": "Tut 5",
  "CREDIT": "randomstarz (ported from https://www.vertexshaderart.com/art/p4K2Kjnj8QoYLkffM)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math"
  ],
  "POINT_COUNT": 36,
  "PRIMITIVE_MODE": "LINES",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0,
    0,
    0,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 2,
    "ORIGINAL_DATE": {
      "$date": 1551422394288
    }
  }
}*/

#define PI radians(180.)

vec3 hsv2rgb (vec3 c)
{
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#if 0
void main ()
{
 float id = vertexId;

   float ux = floor( id / 6. ) + mod( id, 2. );
   float vy = mod( floor( id / 2. ) + floor( id / 3. ), 2. );

   float nSides = 6.;

   float angle = ux * 2. * PI / nSides;
   float c = cos( angle );
    float s = sin( angle );

    float radius = vy + 1.;

    float x = c * radius;
    float y = s * radius;

   //float x = ux;
   //float y = vy;

    vec2 xy = vec2( x, y );
    gl_Position = vec4( xy * .1, 0, 1 );
    v_color = vec4( .5, .7, .9, 1 );
}
#endif

vec2 getCirclePoint ( float id, float nSides )
{

   float ux = floor( id / 6. ) + mod( id, 2. );
   // id = 0 1 2 3 4 5 6 7 8 9 10 11 12 13
    // 0 0 0 0 0 0 1 1 1 1 1 1 2 2
    // 0 1 0 1 0 1 0 1 0 1 0 1 0 1
    // ux = 0 1 0 1 0 1 1 2 1 2 1 2 2 3
   float vy = mod( floor( id / 2. ) + floor( id / 3. ), 2. );
    // id = 0 1 2 3 4 5 6 7 8 9 10 11 12 13
    // 0 0 1 1 2 2 3 3 4 4 5 5 6 6
    // 0 0 0 1 1 1 2 2 2 3 3 3 4 4
    // 0 0 1 2 3 3 5 5 6 7 8 8 10 10
    // vy = 0 0 1 0 1 1 1 1 0 1 0 0 0 0

   // 0 0
    // 1 0
    // 0 1
    // 1 0
    // 0 1
    // 1 1
    // 1 1
    // 2 1

   float angle = ux * 2. * PI / nSides;
   float c = cos( angle );
    float s = sin( angle );

    float radius = vy + 1.;

    float x = c * radius;
    float y = s * radius;

    return vec2( x, y );
}

void main ()
{

 float nSides = 8.;
   vec2 circleXY = getCirclePoint( vertexId, nSides );
   //circleXY *= vec2( 2. );

   // lol

   vec2 xy = circleXY;

   float aspect = resolution.x / resolution.y;
   //gl_Position = vec4( xy * .1, 0, 1 );
    gl_Position = vec4( xy * .1, 0, 1 ) * vec4( 1, aspect, 1, 1 );
    v_color = vec4( .5, .7, .9, 1 );
}