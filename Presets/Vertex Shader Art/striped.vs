/*{
  "DESCRIPTION": "striped",
  "CREDIT": "visy (ported from https://www.vertexshaderart.com/art/FsHtLXJDGt87mpMLt)",
  "ISFVSN": "2",
  "MODE": "VERTEX_SHADER_ART",
  "CATEGORIES": [
    "Math",
    "Animated"
  ],
  "POINT_COUNT": 24693,
  "PRIMITIVE_MODE": "LINE_STRIP",
  "LINE_SIZE": "NATIVE",
  "BACKGROUND_COLOR": [
    0.8,
    1,
    0.9764705882352941,
    1
  ],
  "INPUTS": [],
  "METADATA": {
    "ORIGINAL_VIEWS": 87,
    "ORIGINAL_DATE": {
      "$date": 1448210120885
    }
  }
}*/

void main()
{
  int vx=int(vertexId/4.),vy=int(mod(vertexId,time*0.0001));

  vec3 rp=vec3(0.+time*1.00,1.+time*1.00,0.+time*.00),rd=rp.xzy;

  for(int j=0;j<10000;j++)
  {
    if(j>vx)
      continue;
    vec3 n=normalize(rp);
    rp=n;
    rd=normalize(rd-dot(n+vec3(cos(rd.z+time*0.00001))*0.01,rd)*n);
    rd=normalize(rd+cross(n+rd,rd)*(sin(float(j)*.007)*10.+cos(float(j)*.009+float(vy)*0.1)+sin(float(j)*.001+float(vy)))*.05);
    rp+=rd*0.02;
  }

  float xx=mod((time-float(vx*(int(time*0.0000001)*int(time*0.00001)))/40000.0+floor(time/0007.)*07.)*time,0.009*time+0.01*cos(time*0.0001));
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
  aspect.x*=1.5;
  aspect.y*=1.3;

  v_color.a=1.;
  v_color.rgb=mix(vec3(.2,.5,.6),vec3(.5,.6,1.+rd.y*10.0+time)*.1,(.5+.5*dot(n,normalize(vec3(0.2,0.2,0.2)))))/xx;

  gl_PointSize=4./(1.+xx*4.);
  gl_Position=vec4(pos.xy/pos.z*aspect,0,1);
}
