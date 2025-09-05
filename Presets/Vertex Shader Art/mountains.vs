/*{
  "DESCRIPTION": "mountains",
  "CREDIT": "kolargon (ported from https://www.vertexshaderart.com/art/ct6NykQPhqWr3A7aC)",
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
    0,
    0,
    0,
    1
  ],
  "INPUTS": [ { "LABEL": "Sound", "NAME": "sound", "TYPE": "audioHistogram" } ],
  "METADATA": {
    "ORIGINAL_VIEWS": 185,
    "ORIGINAL_DATE": {
      "$date": 1538862773390
    }
  }
}*/


//Simple study for glslsandbox fragment shader to vertexshaderart vertex shader conversion - WORK IN PROGRESS
//inspired from http://glslsandbox.com/e#49260.0
//2 KParameters added for import and control in K Machine (https://itunes.apple.com/app/k-machine/id1095617380?mt=8)

#define ITERS 8.

#define speedFactor 25.//KParameter 1>>100.0
#define soundFactor 5.0//KParameter 5.0>>30.
#define sizeFactor 1.0//KParameter 0.2>>2.

void main ()
{

  float maxFinalSquareSideSize = floor(sqrt(vertexCount));
  float finalMaxVertexCount = pow(maxFinalSquareSideSize,2.);

  float maxVerticesPerLine = floor(maxFinalSquareSideSize *resolution.x/resolution.y);

  //vertexResolution.x = number of elements in a line as x value for local resolution
  //vertexResolution.y = number of possible lines with the given vertexCount
  vec2 vertexResolution = vec2(maxVerticesPerLine, floor(finalMaxVertexCount/maxVerticesPerLine));

  //Calculate the final number of elements
  float finalVertexCount = vertexResolution.x*vertexResolution.y;

  //and adjust finalVertexId
  float finalVertexId = mod(vertexId,finalVertexCount);

  //Calculate the position of the elements based on their finalVertexId
  //simfragCoord <=> gl_FragCoord of the fragment shader

  vec2 simfragCoord = vec2(mod(finalVertexId, vertexResolution.x),floor(finalVertexId / vertexResolution.x));

  //relative coordinate of the vertex (cordinates range 0. to 1.)
  float u = (simfragCoord.x /vertexResolution.x);
  float v = (simfragCoord.y /vertexResolution.y);

  //calculate coordinates range -1. to 1.

  float fact = 2.*sizeFactor;
  float ux = fact*(u - 0.5);
  float vy = fact*(v - 0.5);

  //Finally set the position of each vertex of the grid
  gl_Position = vec4(ux, vy, 0., 1.);

  //Calculate the best possible pointSize to fill the screen
  gl_PointSize = 2.*resolution.y/vertexResolution.y;

  //create the surfacePosition (glslsandbox parameter ...not used here)
  //vec2 surfacePosition = vec2(ux,vy);

  float snd = soundFactor*texture(sound, vec2(0., 0.2)).r;
  //snd+= +0.001*time;//add a little something to avoid total flatnes;

  //////////////////////////////////////////////////////////////////////////////////////////
  ///Below we import fragment shader logic/code almost unmodify from glslsandbox
  //gl_FragCoord is replaced with the new simfragCoord
  //////////////////////////////////////////////////////////////////////////////////////////

  vec2 position = vec2(simfragCoord.x, simfragCoord.y);
  vec2 res = vec2(vertexResolution.x, vertexResolution.y);
  vec2 fragCoord = vec2(u,v);

   vec3 d = normalize( vec3( (position.xy - res.xy * .5) / vertexResolution.y, .15));

 vec3 p, c, f, g=d, o, y1=vec3(1.0,1.5,0.0);

  o.y = 4. + 4.8*cos((o.x=0.1)*(o.z=time * speedFactor));
 o.x -= sin(time) + 3.0;

    for( float i=.0; i<ITERS; i+=.05 ){
        f = fract(c = o += d*i*.1);
 p = floor( c )*.4;
        if( cos(p.z) + sin(p.x) > ++p.y/snd ) {
      g = (f.y-.04*cos((c.x+c.z)*10.)>.7?y1:f.x*y1.yxz) / i;
        break;
        }
    }

  v_color = vec4(g,1.0);

}