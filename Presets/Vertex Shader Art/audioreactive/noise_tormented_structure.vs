/*{
  "DESCRIPTION": "noise tormented structure",
  "CREDIT": "kolargon (ported from https://www.vertexshaderart.com/art/eh4QC67q3gssnkYYv)",
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
    "ORIGINAL_VIEWS": 379,
    "ORIGINAL_LIKES": 2,
    "ORIGINAL_DATE": {
      "$date": 1516102797953
    }
  }
}*/

//In progress. Based on http://glslsandbox.com/e#42523.0

#define ITERS 40
#define M_PI 3.1415926535897932384626433832795

#define DEBUG 1
#define TAU 6.28318530718

//KDrawmode=GL_POINTS
//KVerticesNumber=100000

#define soundFactor 1.0//KParameter 1.0>>5.
#define screenSizeRation 1.0//KParameter 0.5>>1.

float pattern(vec2 p){p.x*=.866;p.x-=p.y*.5;p=mod(p,1.);return p.x+p.y<1.?0.:1.;}

void main ()
{

  //float finalVertexCount = vertexCount;//max((0.5*snd)*vertexCount,5000.);

  float ratioXforY = resolution.x/resolution.y;

  float finalVertexCount = floor(vertexCount*ratioXforY);

  vec2 finalResolution = vec2(sqrt(ratioXforY * finalVertexCount), sqrt(ratioXforY * finalVertexCount)/ratioXforY);

  //float numAcrossDown = floor(sqrt(finalVertexCount));

  //float ratio = resolution.y/numAcrossDown;

  //float maxVertexCount = numAcrossDown* numAcrossDown;

  float finalVertexId = mod(vertexId, finalVertexCount);

  float x = mod(finalVertexId, finalResolution.x);
  float y = floor(finalVertexId / finalResolution.y);

  float u = (x / finalResolution.x);// * (resolution.y/resolution.x);
  float v = (y / finalResolution.y);

  float snd = texture(sound, vec2(0.2, u)).r;
  snd = soundFactor*pow(0.1+snd,2.);

  float ux = ( u * 2.0 - 1.0) * (finalResolution.x/resolution.x);

  float sndOffset = snd;
  if(v>0.5)
    sndOffset = -snd;
  float vy = sndOffset+( v * 2.0 - 1.0)* (finalResolution.y/resolution.y);

  //apply fragment logic

  vec2 surfacePosition = vec2(0.,0.);

 vec2 p = vec2(x,y);

 vec2 uv1=(p.xy*2.-finalResolution.xy)/min(finalResolution.x,finalResolution.y);
 uv1 += surfacePosition;
 float dp = dot(uv1,uv1);
 uv1 /= 1.-dp*dp;

 float a=0.,d=dot(uv1,uv1),s=0.,t=fract(time*.3),v1=0.;
 for(int i=0;i<8;i++){s=fract(t+a);v+=pattern(uv1*(pow(2.,(1.-s)*8.))*.5)*sin(fract(t+a)*3.14);a+=.125;}

  gl_PointSize = (resolution.y/finalResolution.y)*2.-1.;

  v_color = vec4(mix(vec3(.7,.8,1),vec3(.8,.8,.9),d)*v*.25,1);;

    gl_Position = vec4(ux-distance(v_color.x,v_color.y )/2., vy, 0, 1);

}