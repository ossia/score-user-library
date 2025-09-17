/*{
  "DESCRIPTION": "sea_urkin",
  "CREDIT": "anon (ported from https://www.vertexshaderart.com/art/YoyxivmzQMzpahR8j)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 10000,
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
    "ORIGINAL_VIEWS": 65,
    "ORIGINAL_DATE": {
      "$date": 1645618126969
    }
  }
}*/


#define timeFactor .1//KParameter .1>>2.
#define PointSizeValue 1.13//KParameter 1.>>4.
#define deltaFactor0 0.//KParameter 0.>>1.
#define deltaFactor1 0.//KParameter 0.>>1.
#define posFactorX 1.//KParameter 0.>>1.
#define posFactorY 0.//KParameter 0.>>1.
#define posFactorZ .79//KParameter 0.>>1.
#define posComp0 3.5//KParameter 0.>>1.

//KDrawmode=GL_POINTS

vec3 osc3(float t, float i)
{
  return vec3(sin(t+i*posFactorX),sin(t+i*posFactorY),sin(t+i*posFactorZ));
}

vec3 osc3Comb(float t, float i) {
  return osc3(t*.3,i) + osc3(t,-1.)*posComp0;
}

vec3 incr(float _t, float _i, vec3 _add, float _l)
{
  vec3 pos = osc3Comb(_t,_i)+_add;

  vec3 posf = fract(pos+.5)-.5;

  float l = length(posf)*2.;
  return (- posf + posf/l)*(1.-smoothstep(_l,1.,l));
}

void main() {

  float localVertexId = floor( mod(vertexId,vertexCount/4.) );

  float t = time*timeFactor;
  float i = localVertexId;

  vec3 pos = osc3Comb(t,i);
  vec3 posDelta = vec3(deltaFactor0,deltaFactor1,0.);

  for (float f = 0.; f < 10.; f++)
  {
   posDelta += incr(t-f*.05,i,posDelta,2.-exp(f*.1));
  }

  posDelta += incr(t,i,posDelta,0.2);

  pos -= osc3(t,-1.)*posComp0;

  pos += posDelta;

  pos.yz *= mat2(.8,.6,-.6,.8);
  pos.xz *= mat2(.8,.6,-.6,.8);

  pos *= 1.;

  pos.z += .7;

  pos.xy *= .6/pos.z;

  gl_Position = vec4(pos.x, pos.y*resolution.x/resolution.y, pos.z*.1, 1);

  if(vertexId<(vertexCount/4.))
  {
    //gl_Position.x = -gl_Position.x;
    //gl_Position.y = -gl_Position.y;
  }
  else
  if(vertexId<(2.*vertexCount/4.))
  {
    gl_Position.x = gl_Position.x;
    gl_Position.y = -gl_Position.y;
  }
  else
  if(vertexId<(3.*vertexCount/4.))
  {
     gl_Position.x = -gl_Position.x;
    gl_Position.y = gl_Position.y;
  }
  else
  if(vertexId<(vertexCount))
  {
     gl_Position.x = -gl_Position.x;
     gl_Position.y = -gl_Position.y;
  }

  gl_PointSize = PointSizeValue;

  v_color = vec4(abs(posDelta/max(length(posDelta),1e-9))*.3+.7,0.2);

}
