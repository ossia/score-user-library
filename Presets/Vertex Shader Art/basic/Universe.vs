/*{
  "DESCRIPTION": "Universe",
  "CREDIT": "P_Malin (ported from https://www.vertexshaderart.com/art/5hbYiwjeJvx8tCTME)",
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
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 19,
    "ORIGINAL_DATE": {
      "$date": 1659034108997
    }
  }
}*/

#define PI radians(180.0)
#define TAU radians(360.0)

float seed;

float fhash(float f)
{
  return fract(sin(f*123.456)*234.5678);
}

float fhash()
{
  seed=fhash(seed);
  return seed;
}

mat2 Rotate(float b)
{
    float c=cos(b),s=sin(b);
    return mat2(c,-s,s,c);
}

float saturate( float x ) { return clamp(x,0.,1.); }

void main() {
  float starCount = 1000.0;

  seed = floor(vertexId / starCount);

  float singlePointCount = 4000.;

  if (vertexId < singlePointCount)
  {
    seed = vertexId / singlePointCount;
  }

  vec3 O = vec3(fhash(), fhash(), fhash()) * 2.0 - 1.0;
  O.z += 1.0;
  O = O * 500.0;

  float R = fhash()*TAU;
  float Q = fhash()*TAU;

  float A = fhash() * 5.0;

  vec3 col = vec3(fhash(), fhash(), fhash());
  col.g = (col.r + col.b) / 2.;

  seed = mod(vertexId, starCount) / starCount;

  float s = -log(fhash());

  float theta=fhash()*TAU + time*.1;
  vec2 es = vec2(1,.5);
  vec2 ePos = vec2(sin(theta),cos(theta))*es*s;

  float rotA = s*A + fhash();

  ePos = ePos * Rotate(rotA);

  float D=dot(ePos,ePos) / dot(es,es);
  float H=((pow(2.7,-D*30.))+2.)*.2;
  float Z=pow((fhash()*2.0-1.),3.0)*H;

  vec3 P = vec3(ePos, Z) * 10.;

  P.yz *= Rotate(R);
  P.xy *= Rotate(Q);

  P = P + O;
  P.z -= time * 20.;
  P.z = mod(P.z, 1000.0);

  ePos = P.xy;
  ePos /= P.z;

  vec2 screenPos = ePos * (resolution.yx / resolution.x);

  gl_PointSize = 1. + 500. / P.z;
  //gl_PointSize = 2.;

  gl_Position=vec4(screenPos,1.0 / vertexId,1);

  vec3 col2 = col + fhash();
  col2 *= .3;

  float fade = (1000.-P.z) / 1000.0;
  col2 *= sqrt(fade);

  v_color=vec4(col2, 0);
}