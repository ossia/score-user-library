/*{
  "DESCRIPTION": "strobes",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/fKYmuHmgGeNTPniPK)",
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
    0.07450980392156863,
    0.07450980392156863,
    0.08627450980392157,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 232,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1538036455501
    }
  }
}*/

#define PI 3.141592653589793238462643383

vec3 hueShift(vec3 color,float hueAdjust){
 const vec3 kRGBToYPrime=vec3(0.299,0.587,0.114);
 const vec3 kRGBToI=vec3(0.596,-0.275,-0.321);
 const vec3 kRGBToQ=vec3(0.212,-0.523,0.311);
 const vec3 kYIQToR=vec3(1.0,0.956,0.621);
 const vec3 kYIQToG=vec3(1.0,-0.272,-0.647);
 const vec3 kYIQToB=vec3(1.0,-1.107,1.704);
 float YPrime=dot(color,kRGBToYPrime);
 float I=dot(color,kRGBToI);
 float Q=dot(color,kRGBToQ);
 float hue=atan(Q,I);
 float chroma=sqrt(I*I+Q*Q);
 hue+=hueAdjust;
 Q=chroma*sin(hue);
 I=chroma*cos(hue);
 vec3 yIQ=vec3(YPrime,I,Q);
 return vec3(dot(yIQ,kYIQToR),dot(yIQ,kYIQToG),dot(yIQ,kYIQToB));
}

//I don't understand how to achieve 3D scenes.
void main(){
  float t=vertexId/vertexCount;
  float aspect=resolution.x/resolution.y;
  float x=cos(((t-(time/9.))+2.4)*25.3),
        y=sin(((t+(time/6.))*5.62)+x);
  x+=sin(t*y*2.);
  vec2 shift=vec2(fract(sin(x*y*522.41)*25.2)-.5,fract(sin(x*y*564.1)*35.2)-.5);
  x+=pow(length(shift),2.5)*shift.x;
  y+=pow(length(shift),2.5)*shift.y;
  gl_Position=vec4(x/aspect,y,0.,1.+(length(shift)*+.1));
  gl_PointSize=1.2+((pow(sin(t*PI),5.)*3.)/((length(shift)*5.)+1.));
  vec3 a=vec3(1.,1.,1.);
  vec3 b=hueShift(vec3(1.,0.,0.),(t*8.)+time);
  v_color=vec4(mix(a,b,clamp(pow(length(shift),2.)*4.,0.,1.)),1.);
}