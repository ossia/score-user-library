/*{
  "DESCRIPTION": "Glitter Spirals",
  "CREDIT": "fizzer (ported from https://www.vertexshaderart.com/art/aMJHfrjJHMKKy4iNi)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated",
    "Particles"
  ],
  "POINT_COUNT": 12849,
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
    "ORIGINAL_VIEWS": 1700,
    "ORIGINAL_LIKES": 7,
    "ORIGINAL_DATE": {
      "$date": 1447757693856
    }
  }
}*/

//
void main()
{
  int vx=int(vertexId/4.),vy=int(mod(vertexId,4.));

  vec3 rp=vec3(0.,1.,0.),rd=rp.xzy;

  for(int j=0;j<100000;j++)
  {
    if(j>vx)
      continue;
    vec3 n=normalize(rp);
    rp=n;
    rd=normalize(rd-dot(n,rd)*n);
    rd=normalize(rd+cross(n,rd)*(sin(float(j)*.007)*10.+cos(float(j)*.009+float(vy)*0.1)+sin(float(j)*.001+float(vy)))*.05);
    rp+=rd*0.02;
  }

  float xx=mod((time-float(vx)/400.0+floor(time/17.)*17.)*.6,1.);
  float ss=mod(vertexId/5.,2.);

  vec3 n=normalize(rp);
  vec3 pos=rp-n*ss*.002+vec3(0.,-pow(xx,2.+cos(float(vx))*.8),0.)*ss;
  float a=time/10.;
  pos.xz*=mat2(cos(a),sin(a),-sin(a),cos(a));
  pos.z+=3.;

  #ifdef FIT_VERTICAL
    vec2 aspect = vec2(resolution.y / resolution.x, 1);
  #else
    vec2 aspect = vec2(1, resolution.x / resolution.y);
  #endif

  v_color.a=1.;
  v_color.rgb=mix(vec3(.2,.5,.6),vec3(.5,.6,1.)*.1,(.5+.5*dot(n,normalize(vec3(1.,1.,0.)))))/xx;

  gl_PointSize=4./(1.+xx*4.);
  gl_Position=vec4(pos.xy/pos.z*aspect,0,1);
}
