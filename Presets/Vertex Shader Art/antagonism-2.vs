/*{
  "DESCRIPTION": "antagonism",
  "CREDIT": "kolargon (ported from https://www.vertexshaderart.com/art/JGbg2hhv422MBQhyP)",
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
    "ORIGINAL_VIEWS": 669,
    "ORIGINAL_LIKES": 5,
    "ORIGINAL_DATE": {
      "$date": 1516117893450
    }
  }
}*/

#define ITERS 40
#define M_PI 3.1415926535897932384626433832795

void main ()
{

  float finalVertexCount = vertexCount;//max((0.5*snd)*vertexCount,5000.);
  float ratio = resolution.x/resolution.y;
  float numAcrossDown = floor(sqrt(finalVertexCount));

  float maxVertexCount = numAcrossDown* numAcrossDown;

  float finalVertexId = mod(vertexId, maxVertexCount);

  float x = mod(finalVertexId, numAcrossDown);
  float y = floor(finalVertexId / numAcrossDown);

  float u = x / numAcrossDown;
  float v = (y / numAcrossDown)*ratio;

  float ux = ( u * 2.0 - 1.0) *1./ratio;
  float vy = ( v/ratio * 2.0 - 1.0);

  float snd = texture(sound, vec2(0.2, u)).r;

  //apply fragment logic

 const float colorCount = 8.0;

 vec2 p = vec2(x,y);
    vec2 res = vec2(numAcrossDown,numAcrossDown);

 vec2 position = abs( p.xy * 2.0 - res) / min(res.x, res.y);
 vec3 destColor = vec3(1., 1.0, 1. );
 float f = 0.1;

 for(float i = 0.001; i < (10.0); i++){

  float s = 2.*snd*cos(sin(10. * time / i )) ;
  float c = tan(cos(0.1* time + i ));
  f +=abs( (0.001+snd/100.) / abs(length( (9.0+snd/100.)* position *f - vec2(c, s)) -0.5));
 }

  gl_PointSize = 1.+snd*2.;// (resolution.y/numAcrossDown) * 1.;//(resolution.y/numAcrossDown)*2.-1.;

  v_color = vec4(vec3(destColor * f), 1.0);
  gl_Position = vec4(ux+v_color.x*sign(ux), vy, 0, 1);
  v_color = vec4(vec3(1.), 1.0);

}