/*{
  "DESCRIPTION": "Mesh Reprojection",
  "CREDIT": "aiekick (ported from https://www.vertexshaderart.com/art/r7tpZqAYFwZsQarPw)",
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
    "ORIGINAL_VIEWS": 606,
    "ORIGINAL_LIKES": 1,
    "ORIGINAL_DATE": {
      "$date": 1488310859625
    }
  }
}*/

vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

mat3 rotx(float a){return mat3(1.,0.,0.,0.,cos(a),-sin(a),0.,sin(a),cos(a));}
mat3 roty(float a){return mat3(cos(a),0.,sin(a),0.,1.,0.,-sin(a),0.,cos(a));}
mat3 rotz(float a){return mat3(cos(a),-sin(a),0.,sin(a),cos(a),0.,0.,0.,1.);}

vec3 to3D( float idx, vec3 side )
{
    float z = floor(idx / (side.x * side.y));
    idx -= (z * side.x * side.y);
    float y = (idx / side.x);
    float x = mod(idx, side.x);
    return vec3(x,y,z);
}

float grow = 1.;

float df(vec3 p)
{
 p.xyz += 1.000*sin( 2.0*p.yzx )*grow;
    p.xyz += 0.500*sin( 4.0*p.yzx )*grow;
    return length(p)-1.;
}

void main()
{
 gl_PointSize = 2.;
 float sideCount = pow(vertexCount, 1./3.);
 vec3 p = to3D(vertexId, vec3(sideCount)) - sideCount * .5;
 float d = df(p);
 vec3 ro = p;
 vec3 rd = normalize(vec3(0) - ro);//
 grow = sin(time * 0.5)*.6;
 float s = 1.;
 for (int i = 0;i <200; i++)
 {
  s = df(ro+rd*d);
  d += abs(s) * .1;
 }

 vec3 pos = ro + rd * d;
 pos *= 0.23;
 pos *= rotx(-time*0.1) * roty(time*0.3);
   pos.y *= resolution.x / resolution.y;
 gl_Position = vec4(pos,1);

   float hue = (time * 0.01 + floor(vertexId) * 1.001);
   v_color = vec4(hsv2rgb(vec3(hue, 1, 1)), 1);
}
